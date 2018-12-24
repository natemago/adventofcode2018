package main

import (
	"bufio"
	"fmt"
	"os"
	"regexp"
	"sort"
	"strconv"
	"strings"
)

type Group struct {
	Type        string
	units       int64
	hitPoints   int64
	attackPower int64
	initiative  int64
	attacks     string
	weaknesses  map[string]bool
	immunities  map[string]bool
}

type Army []*Group

func (g *Group) EffectivePower() int64 {
	return g.units * g.attackPower
}

func (g *Group) HowMuchDamageTo(dg *Group) int64 {
	if _, ok := dg.immunities[g.attacks]; ok {
		return 0 // immune
	}
	var fac int64 = 1
	if _, ok := dg.weaknesses[dg.attacks]; ok {
		fac = 2
	}
	return g.EffectivePower() * fac
}

func (g *Group) SelectNextTarget(army Army) *Group {
	if len(army) == 0 {
		return nil
	}
	sort.Slice(army, func(i, j int) bool {
		a := army[i]
		b := army[j]
		dmgToA := g.HowMuchDamageTo(a)
		dmgToB := g.HowMuchDamageTo(b)
		if dmgToA == dmgToB {
			return a.initiative > b.initiative
		}
		return dmgToA > dmgToB
	})

	return army[0]
}

func (g *Group) ReceiveDamage(damage int64) {
	killedUnits := damage / g.hitPoints
	g.units -= killedUnits
}

func (g *Group) Alive() bool {
	return g.units > 0
}

func SelectionPhase(immuneSystem, infection Army) []func() {
	targets := []func(){}

	all := append(immuneSystem, infection...)
	sort.Slice(all, func(i, j int) bool {
		if all[i].EffectivePower() == all[j].EffectivePower() {
			return all[i].initiative > all[j].initiative
		}
		return all[i].EffectivePower() == all[j].EffectivePower()
	})

	for _, group := range all {
		targets = append(targets, func(g *Group) func() {
			return func() {
				targetArmy := immuneSystem
				if g.Type == "immunity" {
					targetArmy = infection
				}
				target := g.SelectNextTarget(targetArmy)
				if target != nil && target.Alive() {
					// deal damage
					target.ReceiveDamage(g.HowMuchDamageTo(target))
				}
			}
		}(group))
	}

	return targets
}

func FilterDeadUnits(army Army) Army {
	b := army[:0]
	for _, g := range army {
		if g.Alive() {
			b = append(b, g)
		}
	}
	return b
}

func FightOneRound(immuneSystem, infection Army) (Army, Army) {
	for _, target := range SelectionPhase(immuneSystem, infection) {
		target()
	}
	// remove dead units
	immuneSystem = FilterDeadUnits(immuneSystem)
	infection = FilterDeadUnits(infection)
	return immuneSystem, infection
}

func Battle(immuneSystem, infection Army) Army {
	for {
		immuneSystem, infection = FightOneRound(immuneSystem, infection)
		if len(immuneSystem) == 0 {
			return infection
		}
		if len(infection) == 0 {
			return immuneSystem
		}
	}
}

func Part1(inputfile string) int64 {
	winner := Battle(loadInput(inputfile))
	var totalUnits int64 = 0
	for _, group := range winner {
		totalUnits += group.units
	}
	return totalUnits
}

func loadInput(filename string) (immunity Army, infection Army) {
	immunity = Army{}
	infection = Army{}

	file, err := os.Open(filename)
	if err != nil {
		panic(err)
	}

	scanner := bufio.NewScanner(file)

	line := ""
	state := ""

	r := regexp.MustCompile("(\\d+) units each with (\\d+) hit points (\\(([^\\(\\)]+)\\) ){0,1}with an attack that does (\\d+) (\\w+) damage at initiative (\\d+)")

	for scanner.Scan() {
		line = scanner.Text()
		line = strings.TrimSpace(line)
		if line == "" {
			continue
		}
		if line == "Immune System:" {
			state = "imm-sys"
			continue
		}
		if line == "Infection:" {
			state = "infect"
			continue
		}
		matches := r.FindStringSubmatch(line)
		if matches == nil {
			panic(fmt.Errorf("Failed to parse line: %s", line))
		}

		group := &Group{
			units:       mustParseInt(matches[1]),
			hitPoints:   mustParseInt(matches[2]),
			attackPower: mustParseInt(matches[5]),
			attacks:     strings.TrimSpace(matches[6]),
			initiative:  mustParseInt(matches[7]),
			immunities:  map[string]bool{},
			weaknesses:  map[string]bool{},
		}

		if matches[4] != "" {
			for _, attrs := range strings.Split(matches[4], ";") {
				if strings.HasPrefix(attrs, "immune to") {
					// immunity
					for _, immunity := range strings.Split(attrs[9:], ",") {
						group.immunities[strings.TrimSpace(immunity)] = true
					}
				} else {
					// weakness
					for _, weakness := range strings.Split(attrs[7:], ",") {
						group.weaknesses[strings.TrimSpace(weakness)] = true
					}
				}
			}
		}

		if state == "imm-sys" {
			group.Type = "immunity"
			immunity = append(immunity, group)
		} else {
			group.Type = "infection"
			infection = append(infection, group)
		}
	}

	return immunity, infection
}

func mustParseInt(str string) int64 {
	i, e := strconv.ParseInt(str, 10, 64)
	if e != nil {
		panic(e)
	}
	return i
}

func main() {
	fmt.Println("Part 1:", Part1("input"))
}
