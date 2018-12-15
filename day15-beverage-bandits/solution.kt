import kotlin.collections.HashMap
import kotlin.collections.HashSet
import java.io.File
import java.util.Arrays

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
        return "Unit[$id] $type ($x, $y)"
    }
}

class CombatMap {
    var units: HashMap<Int, Unit> = HashMap<Int, Unit>()
    var map:Array<IntArray> = arrayOf()
    var width: Int = 0
    var height: Int = 0

    fun loadMapFromFile(filename:String) {
        var y = 0
        var uid = 0
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

    fun getMoveableLocations(fromPoint:Pair<Int, Int>):Array<Pair<Int, Int>> {
        var locations:Array<Pair<Int,Int>> = arrayOf()
        val (x, y) = fromPoint
        if ((x + 1) < width && map[y][(x+1)] >= 0){
            // down
            locations += arrayOf(Pair((x+1), y))
        }
        if ((x - 1) >= 0 && map[y][(x-1)] >= 0){
            locations += arrayOf(Pair((x-1), y))
        }
        if ((y + 1) < height && map[(y+1)][x] >= 0){
            locations += arrayOf(Pair(x, y+1))
        }
        if ((y - 1) >= 0 && map[(y-1)][x] >= 0){
            locations += arrayOf(Pair(x, y-1))
        }
        return locations
    }

    fun findNearestUnitOf(fromThisPoint: Pair<Int, Int>, unitType: String):Pair<Unit, Array<Pair<Int,Int>>>? {
        // BFS from the given point to all available moveable positions until
        // one (or more) points with the given unit type is found.

        // an alternative would be to calculate the distance to every unit of the given
        // type using A* to find the shortest path.

        // will have to do it with A*

        var q:MutableList<qentry> = mutableListOf()
        var seen:HashSet<String> = HashSet<String>()
        var min_dist:Int = -1
        var found:MutableList<qentry> = mutableListOf()
        seen.add("${fromThisPoint}")


        for (point in getMoveableLocations(fromThisPoint)){
            q.add(qentry(point, arrayOf(fromThisPoint), 0))
        }

        while(q.size > 0){
            val qe = q[0]
            q.remove(qe)
            //println("Checking: ${qe.point}")
            if (seen.contains("${qe.point}")){
                continue
            }
            val (x,y) = qe.point
            if (map[y][x] > 0){
                val unit = units.get(map[y][x])
                if (unit != null && unit.type == unitType){
                    if ( min_dist == -1 || min_dist >= qe.value ){
                        min_dist = qe.value
                        found.add(qe)
                    }
                }
            }
            if (min_dist == -1 || min_dist > (qe.value + 1)) {
                for(point in getMoveableLocations(qe.point)){
                    if (!seen.contains("${point}")) {
                        q.add(qentry(point, qe.path + arrayOf(point), qe.value + 1))
                    }
                }
            }
        }

        if (found.size > 0){
            val qe = found[0]
            val (x,y) = qe.point
            val unit = units[map[y][x]]
            if (unit == null){
                return null
            }
            return Pair(unit, qe.path)
        }
        
        return null
    }
}

class qentry(val _point:Pair<Int, Int>, val _path:Array<Pair<Int, Int>>, val _value: Int){
    val point = _point
    val path = _path
    val value = _value

}


fun main(){
    var combatMap = CombatMap()
    combatMap.loadMapFromFile("input")
    val u0 = combatMap.units[0]
    val u1 = combatMap.units[1]
    if (u0 == null || u1 == null){
        println("Nope")
        return
    }
    val found = combatMap.findNearestUnitOf(Pair(u0.x, u0.y), "E")
    println(found)
}