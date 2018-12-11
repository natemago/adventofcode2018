PUZZLE_INPUT=6548
#PUZZLE_INPUT=18

declare -A CACHE
declare -A NCACHE

result=""
function get_power(){
    local x=$1
    local y=$2
    local rackID=$(( x + 10 ))
    local power=$((    (((((rackID * y) + PUZZLE_INPUT) * rackID) / 100) % 10) - 5  ))
    
    result=$power
}


function sum_power_cell(){
    local x=$1
    local y=$2
    local n=$3
    local A=${CACHE["$((x-1)):$((y-1))"]}
    local B=${CACHE["$((x+n-1)):$((y-1))"]}
    local C=${CACHE["$((x-1)):$((y+n-1))"]}
    local D=${CACHE["$((x+n-1)):$((y+n-1))"]}
    result=$(( D-C-B+A ))
}

function calculate_sums(){
    local upto=$1
    local x=1
    local y=1
    local px=0
    local py=0
    local pa=0

    for (( y = 1; y <= upto; y++)); do
        for (( x = 1; x <= upto; x++)); do
            px=${CACHE["$((x-1)):$y"]}
            py=${CACHE["$x:$((y-1))"]}
            pa=${CACHE["$((x-1)):$((y-1))"]}
            get_power $x $y
            CACHE["$x:$y"]=$(( px + py - pa + result ))
        done
        echo "[generated row $y of $upto]"
    done
}


function part1(){
    local max=-101010101010001010101
    local i=0
    local j=0
    local maxx=-1
    local maxy=-1

    for i in {1..298}; do
        for j in {1..298}; do
            sum_power_cell $j $i 3
            if (( result > max )); then
                max=$result
                maxx=$j
                maxy=$i
            fi
        done
        echo "... $i"
    done
    result=$max
    echo "Coords: $maxx,$maxy"
}



function part2(){
    local max=-101010101010001010101
    local i=0
    local j=0
    local n=3
    local maxx=-1
    local maxy=-1
    local maxn=0

    while (( n <= 150  )); do
        i=0
        d=`date`
        echo "Checking $n: $d"
        while (( i <= (300-n) )); do
            j=0
            while (( j <= (300-n) )); do
                sum_power_cell $((j + 1)) $((i + 1)) $n
                #echo "Sum at $i, $j = $result ($n)"
                if (( result > max )); then
                    max=$result
                    maxx=$((j + 1))
                    maxy=$((i + 1))
                    maxn=$n
                    echo "Max: @$maxn, v=$max, ($maxx, $maxy)"
                fi
                j=$(( j + 1 ))
            done
            i=$(( i + 1))
        done
        n=$(( n + 1 ))

    done
    result=$max
    echo "Coords: $maxx,$maxy,$maxn"
}

calculate_sums 300
echo "Sums calculated."

part1
part2

