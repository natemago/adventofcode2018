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
	ID          int
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
	damage := g.EffectivePower()
	if _, ok := dg.weaknesses[g.attacks]; ok {
		damage *= 2
	}
	return damage
}

func (g *Group) ReceiveDamage(damage int64) {
	killedUnits := damage / g.hitPoints
	g.units -= killedUnits
	if g.units < 0 {
		g.units = 0
	}
}

func (g *Group) Alive() bool {
	return g.units > 0
}

func (g *Group) String() string {
	return fmt.Sprintf("Group %d of %s, %d units, %d attack power, %d hit points, %d initiative with %d effective power. Attacks: [%s] Weaknesses: %v. Immunities: %v",
		g.ID, g.Type, g.units, g.attackPower, g.hitPoints, g.initiative, g.EffectivePower(), g.attacks, g.weaknesses, g.immunities)

}

func (g *Group) Clone() *Group {
	clone := &Group{
		ID:          g.ID,
		Type:        g.Type,
		attackPower: g.attackPower,
		attacks:     g.attacks,
		hitPoints:   g.hitPoints,
		immunities:  g.immunities,
		initiative:  g.initiative,
		units:       g.units,
		weaknesses:  g.weaknesses,
	}
	return clone
}

func FilterDeadUnits(army Army) Army {
	b := Army{}
	for _, g := range army {
		if g.Alive() {
			b = append(b, g)
		}
	}
	return b
}

func Battle(immuneSystem, infection Army) Army {
	all := append(Army{}, immuneSystem...)
	all = append(all, infection...)
	count := 0
	for {

		selectedTargets := map[*Group]*Group{}
		targets := map[*Group]bool{}
		targSelection := append(Army{}, all...)

		sort.SliceStable(targSelection, func(i, j int) bool {
			a := targSelection[i]
			b := targSelection[j]

			if a.EffectivePower() == b.EffectivePower() {
				return a.initiative > b.initiative
			}
			return a.EffectivePower() > b.EffectivePower()
		})

		for _, group := range targSelection {
			oppositeArmy := infection
			if group.Type == "infection" {
				oppositeArmy = immuneSystem
			}
			target := SelectTarget(group, oppositeArmy, targets)
			selectedTargets[group] = target
			if target != nil {
				targets[target] = true
			}
		}

		sort.SliceStable(all, func(i, j int) bool {
			a := all[i]
			b := all[j]
			return a.initiative > b.initiative
		})
		attacks := 0
		for _, group := range all {
			if !group.Alive() {
				immuneSystem = FilterDeadUnits(immuneSystem)
				infection = FilterDeadUnits(infection)
				continue
			}
			op := selectedTargets[group]
			if op == nil || !op.Alive() {
				immuneSystem = FilterDeadUnits(immuneSystem)
				infection = FilterDeadUnits(infection)
				continue
			}

			prevUnits := op.units
			op.ReceiveDamage(group.HowMuchDamageTo(op))
			if prevUnits > op.units {
				attacks++
			}
			immuneSystem = FilterDeadUnits(immuneSystem)
			infection = FilterDeadUnits(infection)

			if len(immuneSystem) == 0 {
				return infection
			}

			if len(infection) == 0 {
				return immuneSystem
			}
		}

		if attacks == 0 {
			// stalemate
			return infection
		}

		all = append(Army{}, immuneSystem...)
		all = append(all, infection...)

		count++

	}
}

func SelectTarget(group *Group, fromArmy Army, selected map[*Group]bool) *Group {
	potential := append(Army{}, fromArmy...)
	sort.SliceStable(potential, func(i, j int) bool {
		a := potential[i]
		b := potential[j]
		if group.HowMuchDamageTo(a) == group.HowMuchDamageTo(b) {
			if a.EffectivePower() == b.EffectivePower() {
				return a.initiative > b.initiative
			}
			return a.EffectivePower() > b.EffectivePower()
		}
		return group.HowMuchDamageTo(a) > group.HowMuchDamageTo(b)
	})

	for _, target := range potential {
		if _, ok := selected[target]; !ok {
			if group.HowMuchDamageTo(target) > 0 {
				return target
			}
		}
	}

	return nil
}

func Boost(immunity Army, boost int64) Army {
	boostedArmy := Army{}
	for _, g := range immunity {
		clone := g.Clone()
		clone.attackPower += boost
		boostedArmy = append(boostedArmy, clone)
	}
	return boostedArmy
}

func Part1(inputfile string) int64 {
	winner := Battle(loadInput(inputfile))
	var totalUnits int64 = 0
	for _, group := range winner {
		totalUnits += group.units
	}
	return totalUnits
}

func Part2(inputfile string) int64 {
	immuneSystem, infection := loadInput(inputfile)
	boost := int64(1)
	for {
		imm := Boost(immuneSystem, boost)
		inf := Boost(infection, 0) // just copy
		winners := Battle(imm, inf)
		if winners[0].Type == "immunity" {
			var totalUnits int64 = 0
			for _, group := range winners {
				totalUnits += group.units
			}
			return totalUnits
		}
		boost++
	}
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
				attrs = strings.TrimSpace(attrs)
				if strings.HasPrefix(attrs, "immune to") {
					// immunity
					for _, immunity := range strings.Split(attrs[9:], ",") {
						group.immunities[strings.TrimSpace(immunity)] = true
					}
				} else {
					// weakness
					for _, weakness := range strings.Split(attrs[8:], ",") {
						group.weaknesses[strings.TrimSpace(weakness)] = true
					}
				}
			}
		}

		if state == "imm-sys" {
			group.ID = len(immunity) + 1
			group.Type = "immunity"
			immunity = append(immunity, group)
		} else {
			group.ID = len(infection) + 1
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
	// immuneSystem, infection := loadInput("input")
	// for _, gg := range immuneSystem {
	// 	fmt.Println(gg.String())
	// }
	// fmt.Println("-------------------------")
	// for _, gg := range infection {
	// 	fmt.Println(gg.String())
	// }
	fmt.Println("Part 2:", Part2("input"))
}
