fun getmatrix (rows, cols) =
    Vector.tabulate (rows, fn _ => Vector.tabulate(cols, fn _ => 0))

fun printRow (row:int vector) =
    let 
        val mapfn = 
            fn i => 
                let 
                    val _ = print( Int.toString(i) ^ " " )
                in 
                    i
                end
    in
        Vector.map mapfn row
    end

fun printMatrix (matrix:int vector vector) =
    let
        val mapfn =
            fn row =>
                let 
                    val _ = printRow(row)
                    val _ = print "\n"
                in
                    row
                end
    in
        Vector.map mapfn matrix
    end


fun vectorReplace(vec:int vector, n: int, s: int, e: int) =
    let 
        val replace =
            fn (i, v) =>
                if (i >= s) andalso (i < e)
                then
                    if v <> 0 then 
                        if v < 0 then v - n
                        else ~v - n
                    else n
                else v
    in
        Vector.mapi replace vec
    end

fun matrixReplace(matrix:int vector vector, n: int, x:int, y:int, width:int, height:int) =
    let
        val endX = x + width
        val endY = y + height
        val mapfn =
            fn (i, row) =>
                if (i >= y) andalso (i < endY) then vectorReplace(row, n, x, endX)
                else row
    in
        Vector.mapi mapfn matrix
    end


fun countNegative(matrix:int vector vector) =
    let
       val rowfold = Vector.foldl(fn (x, a) => if x < 0 then a + 1 else a)
    in
        Vector.foldl(fn (row, a) => a + (rowfold 0 row) ) 0 matrix
    end

fun readInput(filename:string) =
    let
        val inpfile = TextIO.openIn filename
    in
        String.tokens(fn (c) => if c = #"\n" then true else false) (TextIO.inputAll inpfile)
    end

fun printstr(strlist:string list) =
    let
        fun pm (p)= 
            let val _ = print (p ^ ", ")
            in p end
    in 
        List.map pm (strlist @ ["\n"])
    end

fun token(t:char) =
    fn (c) => 
        c = t

fun parseLine(line:string)=
    let
        val segments = String.tokens(token #" ") line
        val idstr = List.nth( segments , 0)
        val id:int = valOf (Int.fromString (String.substring(idstr, 1, ((String.size idstr) - 1)  )))
        val xy = String.tokens(token #",") (List.nth(segments, 2))
        val x:int = valOf( Int.fromString (List.nth(xy, 0)))
        val y:int = valOf ( Int.fromString (  String.substring( (List.nth(xy, 1), 0, (String.size((List.nth(xy, 1))) -1 ) ) )  ))
        val wh = String.tokens(token #"x") (List.nth(segments, 3))
        val width:int = valOf(Int.fromString (List.nth(wh, 0)))
        val height:int = valOf(Int.fromString (List.nth(wh, 1)))
    in
        (id, x,y,width,height)
    end


fun spanNeg(m:int vector, s:int, e:int) =
    Vector.foldli(fn (i, x, a) => if (i >= s) andalso (i < e) then if x < 0 then true else a else a) false m

fun sliceOverlaps(m:int vector vector, x:int, y:int, width:int, height:int) = 
    let
        val endX = x + width
        val endY = y + height
    in
        Vector.foldli(fn (i, row, a) => if (i >= y) andalso (i < endY) then a orelse (spanNeg(row, x, endX)) else a) false m
    end

fun findNonOverlapping(m:int vector vector, instuctions:string list) =
    let
        fun nonoverlapping (line) =
            let
                val (id,x,y,width,height) = (parseLine(line))
            in
                not (sliceOverlaps(m, x, y, width, height))
            end
    in
        List.hd (List.filter nonoverlapping instuctions)
    end
    


fun part1(inputfile:string, matrix:int vector vector) =
    let
        val inplines = readInput inputfile
        val count = (List.length(inplines))

        fun transformmatrix(line:string, m:int vector vector) =
            let
                val (id,x,y,width,height) = parseLine line
            in
                matrixReplace(m, id, x, y, width, height)
            end
        fun transform(i:int, count:int, m:int vector vector) =
            if i = count then
                m
            else
                transform( (i+1), count, transformmatrix( (List.nth(inplines, i)), m ))
    in
        countNegative(transform(0, List.length(inplines), matrix))
    end


fun part2(inputfile:string, matrix:int vector vector) =
    let 
        val inplines = readInput inputfile
        val count = (List.length(inplines))

        fun transformmatrix(line:string, m:int vector vector) =
            let
                val (id,x,y,width,height) = parseLine line
            in
                matrixReplace(m, id, x, y, width, height)
            end
        fun transform(i:int, count:int, m:int vector vector) =
            if i = count then
                m
            else
                transform( (i+1), count, transformmatrix( (List.nth(inplines, i)), m ))
    in
        findNonOverlapping(transform(0, count, matrix), inplines)
    end

fun main () =
    let
        val _ = print ("Part 1: " ^ (Int.toString (part1 ("input", getmatrix(1000, 1000)))) ^ "\n\n")
        val _ = print ("Part 2: " ^ (part2 ("input", getmatrix(1000, 1000)) ) ^ "\n")
    in
        true
    end
  

val _ = main()