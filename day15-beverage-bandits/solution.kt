import kotlin.collections.HashMap
import kotlin.collections.HashSet
import java.io.File
import java.util.Arrays
import kotlin.math.*

class Unit(val uid: Int, val utype: String, val posx: Int, val posy: Int) {
    val id: Int = uid
    val type: String = utype
    var x: Int = posx
    var y: Int = posy
    var attackPower: Int = 3
    var hitPoints: Int = 200

    fun takeHit(withPower: Int){
        hitPoints -= withPower
    }

    fun alive(): Boolean {
        return hitPoints >= 0
    }

    override fun toString():String{
        return "Unit[$id] $type ($x, $y) {$hitPoints}"
    }
}

class CombatMap {
    var units: HashMap<Int, Unit> = HashMap<Int, Unit>()
    var map:Array<IntArray> = arrayOf()
    var width: Int = 0
    var height: Int = 0

    fun loadMapFromFile(filename:String) {
        var y = 0
        var uid = 1
        File(filename).forEachLine  { line:String ->
            var row = intArrayOf()
            var x = 0
            for (c in line ){
                if (c.toString() == "#"){
                    row += intArrayOf(-1)
                }else if (c.toString() == ".") {
                    row += intArrayOf(0)
                }else{
                    val unit = Unit(uid, c.toString(), x, y)
                    units.put(uid, unit)
                    println("Unit found ${uid}[${c}] at $x,$y")
                    row += intArrayOf(uid)
                    uid++
                }
                x++
            }
            width = x
            y++
            this.map += row
        }
        height = y
    }

    fun getUnitsSorted():List<Unit>{
        var sortedUnits:MutableList<Unit> = units.values.toMutableList()

        sortedUnits.sortWith(compareBy ({it.y},{it.x}) )

        return sortedUnits
    }

    fun getUnitsOfType(type:String):List<Unit> {
        return getUnitsSorted().filter { it.type == type && it.alive()}
    }

    fun findNearestUnit(from:Pair<Int,Int>, ofType:String):Pair<Unit, List<Pair<Int,Int>>>? {
      // bfs
      var visited:HashSet<Pair<Int,Int>> = HashSet()
      var cameFrom:HashMap<String, Pair<Int,Int>> = HashMap()
      var q:MutableList<Pair<Int, Int>> = mutableListOf()
      var path:MutableList<Pair<Int,Int>> = mutableListOf()
      var unit:Unit? = null

      q.add(from)

      while(q.size > 0){
        //println("q=${q.size}")
        val curr:Pair<Int,Int> = q.get(0)
        q = q.drop(1).toMutableList()
        if (visited.contains(curr)){
          continue
        }
        visited.add(curr)

        if(map[curr.second][curr.first] > 0 && units[map[curr.second][curr.first]]!!.type == ofType){
          // found, reconstruct path
          var p:Pair<Int, Int>? = curr
          while (p != null){
            path.add(p)
            //println("$p came from ${cameFrom["$p"]}")
            p = cameFrom["$p"]
          }
          path = path.asReversed()
          unit = units[map[curr.second][curr.first]]!!
          break
        }
        val (x,y) = curr
        val prev:Pair<Int,Int>? = cameFrom["$curr"]
        for(p:Pair<Int,Int> in listOf(Pair(x,y-1),Pair(x-1,y),Pair(x+1,y),Pair(x,y+1))){
          val (xx,yy) = p
          if(xx >=0 && xx < width && yy >=0 && yy < height){
            // inside the map
            val c = map[yy][xx]
            if (c >= 0 && (prev == null || prev != p) && !visited.contains(p)){
              if(c > 0){
                if(units[c]!!.type != ofType) {
                  continue
                }
              }
              q.add(p)
              cameFrom["$p"] = curr
            }
          }
        }
      }
      if(unit == null){
        return null
      }
      return Pair(unit, path)
    }

    fun findNearestUnitFrom(from:Unit):Pair<Unit, List<Pair<Int,Int>>>? {
      var minPath:Pair<Unit, List<Pair<Int, Int>>>? = null
      val (x,y) = Pair(from.x, from.y)
      for(p:Pair<Int,Int> in listOf(Pair(x,y-1),Pair(x-1,y),Pair(x+1,y),Pair(x,y+1))){
        if(map[p.second][p.first] == -1){
          continue
        }else if(map[p.second][p.first] > 0){
          val u = units[map[p.second][p.first]]!!
          if (u.type == from.type){
            continue
          }
          if(minPath == null || minPath.second.size > 1) {
            minPath = Pair(u, listOf(p))
            continue
          }
        }
        val n = findNearestUnit(p, if (from.type == "G") "E" else "G")
        if (n != null){
          if(minPath == null || n.second.size < minPath.second.size){
            minPath = n
          }
        }
      }
      return minPath
    }

    fun getNeighbourUnits(unit:Unit):List<Unit>? {
        val x = unit.x
        val y = unit.y
        var neighbours:MutableList<Unit> = mutableListOf()
        for (p in listOf(Pair(x, y-1),Pair(x-1, y),Pair(x+1, y),Pair(x, y+1))) {
            if((p.first >= 0) && (p.first < width) && (p.second >= 0) && (p.second < height)) {
                val v = map[p.second][p.first]
                if (v > 0) {
                    neighbours.add(units[v]!!)
                }
            }
        }
        return neighbours
    }

    fun moveUnit(unit: Unit, toPoint:Pair<Int,Int>){
        val px = unit.x
        val py = unit.y
        val (x,y) = toPoint
        unit.x = x
        unit.y = y
        map[py][px] = 0
        map[unit.y][unit.x] = unit.uid
    }

    fun moveUnits():Boolean{
        val unitsSorted = getUnitsSorted()
        var lastDeathAt = -1;
        var i = 0;
        for (unit in unitsSorted){
            if (unit.alive()) {
                i++;
                //val closestPair = getClosestUnitOfType2(unit, if (unit.type == "G") "E" else "G" )
                val closestPair = findNearestUnitFrom(unit)
                if (closestPair == null) {
                    continue
                }
                val (c, path) = closestPair
                println("To $unit closest is $c over $path")
                if (path.size > 1) {
                    moveUnit(unit, path[0])
                    println("Moved $unit to ${path[1]}")
                }
                if (thenAttack(unit)) {
                    lastDeathAt = i;
                }
            }
        }
        return lastDeathAt == i
    }

    fun thenAttack(unit:Unit):Boolean {
        var hu = getPossibleUnitToHit(unit)
        if (hu != null && hu.type != unit.type){
            hu.takeHit(unit.attackPower)
            println(" $unit hitting $hu")
            if (!hu.alive()){
                // hu died
                map[hu.y][hu.x] = 0 // remove from map
                println("$hu died")
                return true
            }
        }
        return false
    }

    fun getPossibleUnitToHit(unit:Unit):Unit? {
        var possible:MutableList<Unit> = getNeighbourUnits(unit)!!.filter ({ it.type != unit.type }).toMutableList()
        if (possible.size > 0) {
            possible.sortWith(compareBy ({ it.hitPoints }, {it.y}, {it.x}))
            return possible[0]
        }
        return null
    }

    fun battle(){
        var cycle:Int = 0

        while (true) {
            println("Round $cycle")
            for (u in units) {
                println("$u")
            }
            // move
            val death = moveUnits()
            // then hit
            //makeHits()
            printMap(null)

            var stillAlive = 0
            for (unit in getUnitsSorted()) {
                if (unit.alive()){
                    stillAlive++
                }
            }
            println("There are $stillAlive units still alive.")
            val goblins = getUnitsOfType("G")
            val elfs = getUnitsOfType("E")
            cycle++
            if (goblins.size == 0 || elfs.size == 0){
                println("Battle ends. Gobilns: ${goblins.size}, Elfs: ${elfs.size}")
                val winners = if (goblins.size > 0) goblins else elfs
                var score = 0
                for (w in winners) {
                    println("Winner: $w")
                    score += w.hitPoints
                }
                if(death){
                    println("Finishes on full round.")
                    score *= (cycle)
                }else{
                    println("Does not finish on full round.")
                    score *= (cycle-1)
                }

                println("Winners have $score points")
                //println("Other value is: ${(score/cycle)*(cycle-1)}")
                break
            }

            if (cycle == 12){
                //break
            }
            println("====================================================\n\n")
            //readLine()
        }
    }

    fun printMap(mark:List<Pair<Int, Int>>?){
        var y = 0
        for (row in map){
            var x = 0
            for (c in row){
                if (mark != null && isIn(Pair(x,y), mark)){
                    print("X")
                    x++
                    continue
                }
                if (c < 0){
                    print("#")
                }else if (c == 0){
                    print(".")
                }else{
                    val unit = units[c]!!
                    print("${unit.type}")
                }
                x++
            }
            println()
            y++
        }
    }
}

fun isIn(p:Pair<Int, Int>, lst:List<Pair<Int,Int>>):Boolean{
    for (pp in lst){
        if(p == pp){
            return true
        }
    }
    return false
}

class qentry(val _point:Pair<Int, Int>, val _path:Array<Pair<Int, Int>>, val _value: Int){
    val point = _point
    val path = _path
    val value = _value
}


fun part2(inpfile:String){
  var elfPoints = 4
  while (true){
    println("********************************************")
    println("\n\n\n\n\n\n")
    println(" ELF POINTS: $elfPoints")
    println("\n\n\n\n\n\n")
    var combatMap = CombatMap()
    combatMap.loadMapFromFile(inpfile)
    for((_,u) in combatMap.units){
      if(u.type == "E"){
        u.attackPower = elfPoints
      }
    }
    combatMap.battle()
    var allAlive = true
    for((_,u) in combatMap.units){
      if(u.type == "E" && !u.alive()){
        allAlive = false
        break
      }
    }
    if(allAlive){
      break
    }
    elfPoints++
  }
  println("Part 2: Elf points: $elfPoints")
}


fun main(args: Array<String>){

    var combatMap = CombatMap()
    combatMap.loadMapFromFile(args[0])
    //combatMap.printMap(null)
    //combatMap.moveUnits()
    //combatMap.makeHits()
    //val u0 = combatMap.units[1]!!
    //val u1 = combatMap.units[combatMap.units.size]!!
    //val path = combatMap.findShortestPath(Pair(u0.x, u0.y), Pair(u1.x, u1.y))
    //println("Path: ${Arrays.toString(path)}")
    //combatMap.printMap(path.toList())
    combatMap.printMap(null)
    combatMap.battle()

    //val path = combatMap.findShortestPath(Pair(1,1), Pair(3,2))
    //println("Path -> $path")

    part2(args[0])
}
