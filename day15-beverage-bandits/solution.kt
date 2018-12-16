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

    fun findShortestPath(A: Pair<Int, Int>, B: Pair<Int, Int>):List<Pair<Int,Int>> {
        // A* path finding
        var evaluated:HashSet<String> = HashSet<String>()
        var openSet:MutableList<Pair<Int,Int>> = mutableListOf()
        var cameFrom:HashMap<String, Pair<Int,Int>> = HashMap()
        var gScore:HashMap<String, Int> = HashMap()
        var fScore:HashMap<String, Int> = HashMap()
        val Infinity = 1000000 // some high number
        var resultPath:MutableList<Pair<Int,Int>> = mutableListOf()

        gScore["$A"] = 0
        fScore["$A"] = getDistanceEstimation(A,B)

        openSet.add(A)

        while (openSet.size > 0) {
            val curr = openSet[0]
            if (curr == B){
                // reconstruct path
                var cameFromPoint = cameFrom["$curr"]
                while (cameFromPoint != null){
                    resultPath.add(cameFromPoint)
                    cameFromPoint = cameFrom["$cameFromPoint"]
                }
                break
            }

            evaluated.add("$curr")
            openSet.remove(curr)

            for (point in getMoveableLocations(curr, B)){
                if(evaluated.contains("$point")){
                    continue
                }
                val tScore = gScore.getOrElse("$curr"){Infinity} + 1 // 1 is the distance to the neigbour
                if (!openSet.contains(point)){
                    openSet.add(point)
                    // sort the open set by fscore
                    openSet.sortWith(compareBy{ fScore.getOrElse("$it"){ Infinity }  })
                }else if (tScore > gScore.getOrElse("$point"){Infinity} ){
                    continue
                }
                cameFrom["$point"] = curr
                gScore["$point"] = tScore
                fScore["$point"] = tScore + getDistanceEstimation(point, B)
            }
        }

        return resultPath.asReversed()
    }

    fun getDistanceEstimation(A: Pair<Int, Int>, B: Pair<Int, Int>):Int{
        // Manhattan distance
        val (ax, ay) = A
        val (bx, by) = B
        return abs(ax - bx) + abs(ay - by)
    }

    fun getClosestUnitOfType(fromUnit: Unit, type:String):Pair<Unit, List<Pair<Int,Int>>>? {
        val unitsOfType:List<Unit> = getUnitsOfType(type).filter{ it.alive() }
        if (unitsOfType.size == 0) {
            println("No units of type $type")
            return null
        }
        println("||$fromUnit|| -> $unitsOfType")
        var shortestPath:List<Pair<Int,Int>> = findShortestPath(Pair(fromUnit.x, fromUnit.y), Pair(unitsOfType[0].x, unitsOfType[0].y))
        var closestUnit:Unit = unitsOfType[0]
        for (unit in unitsOfType.drop(1)){
            val path = findShortestPath(Pair(fromUnit.x, fromUnit.y), Pair(unit.x, unit.y))
            if (path.size > 0 && path.size < shortestPath.size){
                shortestPath = path
                closestUnit = unit
            }
        }
        return Pair(closestUnit, shortestPath)
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
    
    fun moveUnits(){
        for (unit in getUnitsSorted()){
            if (unit.alive()) {
                val closestPair = getClosestUnitOfType(unit, if (unit.type == "G") "E" else "G" )
                if (closestPair == null) {
                    continue
                }
                val (c, path) = closestPair
                println("To $unit closest is $c over $path")
                if (path.size > 1) {
                    moveUnit(unit, path[1])
                    println("Moved $unit to ${path[1]}")
                }
            }
        }
        printMap(null)
    }
    
    fun makeHits() {
        for (unit in getUnitsSorted()){
            if (unit.alive()){
                var hu = getPossibleUnitToHit(unit)
                if (hu != null && hu.type != unit.type){
                    hu.takeHit(unit.attackPower)
                    println(" $unit hitting $hu")
                    if (!hu.alive()){
                        // hu died
                        map[hu.y][hu.x] = 0 // remove from map
                        println("$hu died")
                    }
                    
                }
            }
        }
    }
    
    fun getPossibleUnitToHit(unit:Unit):Unit? {
        var possible:MutableList<Unit> = mutableListOf()
        for (p in arrayOf(Pair(unit.x, unit.y-1), Pair(unit.x-1, unit.y), Pair(unit.x+1, unit.y), Pair(unit.x, unit.y+1))){
            val (x,y) = p
            if ( (x >= 0) && (x < width) && (y >= 0) && (y < height)){
                val v = map[y][x]
                if (v > 0){
                    val res = units[v]!!
                    possible.add(res)
                }            
            }
        }
        if (possible.size > 0) {
            possible.sortWith(compareBy { it.hitPoints })
            return possible[0]
        }
        return null
    }
    
    fun getMoveableLocations(fromPoint:Pair<Int, Int>, including:Pair<Int,Int>):Array<Pair<Int, Int>> {
        var locations:Array<Pair<Int,Int>> = arrayOf()
        val (x, y) = fromPoint
        
        
        if ((y + 1) < height){
            val v = map[y + 1][x]
            if (v == 0 || (v > 0) && (Pair(x,y+1) == including)){
                locations += arrayOf(Pair(x,y+1))
            }
        }
        if ((x + 1) < width){
            val v = map[y][x+1]
            if (v == 0 || (v > 0) && (Pair(x+1,y) == including)){
                locations += arrayOf(Pair(x+1,y))
            }
        }
        if ((y - 1) < width){
            val v = map[y-1][x]
            if (v == 0 || (v > 0) && (Pair(x,y-1) == including)){
                locations += arrayOf(Pair(x,y-1))
            }
        }
        if ((x - 1) >= 0){
            val v = map[y][x-1]
            if (v == 0 || (v > 0) && (Pair(x-1,y) == including)){
                locations += arrayOf(Pair(x-1,y))
            }
        }
        
        return locations
    }
    
    fun battle(){
        var cycle:Int = 0
        
        while (true) {
            println("Round $cycle")
            // move
            moveUnits()
            // then hit
            makeHits()
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
                    score += w.hitPoints
                }
                score *= (cycle)
                println("Winners have $score points")
                break
            }
            if (cycle == 12){
                //break
            }
            println("====================================================")
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
            //println(" $p == $pp")
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


fun main(){
    var combatMap = CombatMap()
    combatMap.loadMapFromFile("input.test")
    //combatMap.printMap(null)
    //combatMap.moveUnits()
    //combatMap.makeHits()
    //val u0 = combatMap.units[1]!!
    //val u1 = combatMap.units[combatMap.units.size]!!
    //val path = combatMap.findShortestPath(Pair(u0.x, u0.y), Pair(u1.x, u1.y))
    //println("Path: ${Arrays.toString(path)}")
    //combatMap.printMap(path.toList())
    combatMap.battle()
    
    //val path = combatMap.findShortestPath(Pair(1,1), Pair(3,2))
    //println("Path -> $path")
}
