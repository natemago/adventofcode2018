import scala.io.Source
import scala.util.matching.Regex


class Point(val px: Long, val py: Long, val pvx: Long, val pvy: Long) {
    var x: Long = px
    var y: Long = py
    var vx: Long = pvx
    var vy: Long = pvy
}

class BoundingBox(val bx1: Long, val bx2: Long, val by1: Long, val by2: Long) {
    var x1: Long = bx1
    var x2: Long = bx2
    var y1: Long = by1
    var y2: Long = by2


    def area(): Long = {
        return (y2 - y1) * (x2 - x1)
    }

    override def toString(): String = {
        var width = (x2 - x1)
        var height = (y2 - 1)
        return "[x1=" + x1 + " x2=" + x2 + " ] /y1=" + y1 + " y2=" + y2 + "/"
    }
}


object Day10Solution{

    def loadInput(filename: String): List[String] = {
        Source.fromFile(filename).getLines().toList
    }

    def pointsAt(points: List[Point], s: Long): List[Point] = {
        points.map((p:Point) => {
            new Point(p.x + s*p.vx,
                      p.y + s*p.vy,
                      p.vx, p.vy)
        })
    }

    def getBoundingBox(points: List[Point]): BoundingBox = {
        var p = points.head
        points.foldLeft(new BoundingBox(p.x,p.x,p.y,p.y))((b:BoundingBox, p:Point) => {
            new BoundingBox (if (p.x < b.x1) p.x else b.x1,
                                if (p.x > b.x2) p.x else b.x2,
                                if (p.y < b.y1) p.y else b.y1,
                                if (p.y > b.y2) p.y else b.y2)
        })
    }


    def parseInput(lines: List[String]): List[Point] = {
        var pattern: Regex = "position=<\\s{0,}(-{0,1}\\d+),\\s+(-{0,1}\\d+)> velocity=<\\s{0,}(-{0,1}\\d+),\\s+(-{0,1}\\d+)>".r
        return lines.map((line: String) => {
            pattern.findFirstMatchIn(line) match {
                case None =>  throw new Exception("Faulty line: " + line)
                case Some(m) => {
                    new Point(m.group(1).toLong, m.group(2).toLong, m.group(3).toLong, m.group(4).toLong)
                }
            }
        })
    }

    def inPoints(x:Int, y:Int, points:List[Point]): Boolean ={
        points.foldLeft(false)((b, p) => if (p.x == x && p.y == y) true else b)
    }

    def printPoints(points:List[Point], b:BoundingBox) = {
        var i = 0
        var j = 0
        for (i <- 0 to (b.y2 - b.y1).toInt) {
            for (j <- 0 to (b.x2 - b.x1).toInt) {
                if (inPoints((j + b.x1).toInt, (i + b.y1).toInt, points) ){
                    print("#")
                }else{
                    print(".")
                }
            }
            println()
        }
    }

    def part1(){
        var points = parseInput(loadInput("input"))
        var i = 0
        var area = getBoundingBox(pointsAt(points, i)).area()
        var mi = i

        for (i <- 1 to 20000) {
            var b = getBoundingBox(pointsAt(points, i))
            var a = b.area()
            if (a < area) {
                area = a
                mi = i
            }
        }
        
        println("Part 1: ")
        printPoints(pointsAt(points, mi), getBoundingBox(pointsAt(points, mi)))
        println("Part 2: The elves would have to wait "+ mi + " seconds.")
    }

    def main(args: Array[String]) {
        part1()
    }
}