from math import log10

type
    Node = ref object
        next: Node
        index: int
        value: int

    Board = ref object
        head: Node
        last: Node
        elf1: Node
        elf2: Node


proc append(board: var Board, node: var Node) =
    if isNil(board.head):
        board.head = node
        board.last = node
        node.next = node
        node.index = 0
    else:
        let p = board.last
        board.last = node
        p.next = node
        node.next = board.head
        node.index = p.index + 1

proc sublist(start: var Node, n: var int):seq[Node] = 
        var res:seq[Node] = @[]
        var p: Node = start
        while n >= 0:
            res.add(p)
            p = p.next
            n = n-1
        return res

proc find(start: Node, n: int):Node =
    var count: int = n
    var curr:Node = start

    while count > 0:
        curr = curr.next
        count = count - 1
    return curr

proc new_board():  Board =
    var board: Board = Board()

    var n1: Node = Node(value: 3)
    var n2: Node = Node(value: 7)

    append(board, n1)
    append(board, n2)

    board.elf1 = n1
    board.elf2 = n2

    return board


proc iterate(board: var Board) =
    let sum:int = board.elf1.value + board.elf2.value
    let n1:int = sum%%10
    let n2:int = (sum/%10)%%10

    var n:Node = Node(value: n1)
    if sum >= 10:
        var nn:Node = Node(value: n2)
        board.append(nn)
    board.append(n)

    board.elf1 = find(board.elf1, (board.elf1.value + 1))
    board.elf2 = find(board.elf2, (board.elf2.value + 1))
    

proc print_board(board: Board) =
    var p:Node = board.head
    while true:
        if p == board.elf1:
            stdout.write "(", p.value, ") "
        elif p == board.elf2:
            stdout.write "[", p.value, "] "
        else:
            stdout.write p.value, " "
        p = p.next
        if p == board.head:
            break
    echo ""

proc part1(n:int) =
    var board: Board = new_board()
    var count:int = 0
    while true:
        iterate(board)
        if board.last.index >= (n + 10):
            break
        count = count + 1
    var p:Node = find(board.head, n)
    stdout.write "Part 1: "
    for i in countup(1, 10):
        stdout.write p.value
        p = p.next
    echo ""

proc get_aggregate_value(board: Board, curr: Node, dn:int): int =
    var sum: int = 0
    var count: int = dn
    var p: Node = curr
    while count > 0:
        sum = sum*10 + p.value
        count = count - 1
        p = p.next
    return sum

proc part2(n:int) =
    var board: Board = new_board()
    var dn:int = int(log10(float(n))) + 1
    var lastdn:Node = board.head
    var curr:int = 0
    var index:int = -1
    while true:
        if board.last.index >= dn:
            while (board.last.index - lastdn.index) > dn:
                if get_aggregate_value(board, lastdn, dn) == n:
                    index = lastdn.index + 1
                    break
                lastdn = lastdn.next
        if get_aggregate_value(board, lastdn, dn) == n:
            index = lastdn.index
            break
        iterate(board)
        curr = curr + 1
    
    echo "Part 2: ", index
part1(793031)
part2(793031)
