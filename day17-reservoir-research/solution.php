<?php


function read_input($filename) {
    $lines = [];

    $fh = fopen($filename, "r");

    if($fh){
        while (($line = fgets($fh)) !== false){
            $line = trim($line);
            preg_match("/y=(\\d+), x=(\\d+)..(\\d+)/", $line, $match);
            if ($match){
                $lines[] = [
                    "x1" => intval($match[2]),
                    "x2" => intval($match[3]),
                    "y1" => intval($match[1]),
                    "y2" => intval($match[1])
                ];
            }else{
                preg_match("/x=(\\d+), y=(\\d+)..(\\d+)/", $line, $match);
                if (!$match){
                    throw new Exception("Failed to parse line $line");
                }
                $lines[] = [
                    "x1" => intval($match[1]),
                    "x2" => intval($match[1]),
                    "y1" => intval($match[2]),
                    "y2" => intval($match[3])
                ];
            }
            
        }
    }

    return $lines;
}

function get_clay_map($readings) {
    $map = [];
    $maxx = null;
    $maxy = null;
    $minx = null;
    $miny = null;

    foreach( $readings as $reading ) {
        for($i = $reading["y1"]; $i <= $reading["y2"]; $i++) {
            if ($maxy == null || $i > $maxy) {
                $maxy = $i;
            }
            if ($miny == null || $i < $miny ) {
                $miny = $i;
            }
            for ($j = $reading["x1"]; $j <= $reading["x2"]; $j++) {
                if ($maxx == null || $j > $maxx) {
                    $maxx = $j;
                }
                if ($minx == null || $j < $minx) {
                    $minx = $j;
                }
                $map["$i:$j"] = "#";
            }
        }
    }

    $map["maxx"] = $maxx + 2;
    $map["minx"] = $minx - 2;
    $map["maxy"] = $maxy;
    $map["miny"] = $miny;

    return $map;
}

function probe_row($map, $row, $x) {
    $left = -1;
    $right = -1;
    for ($i = $x; $i >= $map["minx"]; $i-- ) {
        if (array_key_exists("$row:$i", $map) && $map["$row:$i"] == "#") {
            $left = $i;
            break;
        }
    }
    if ($left > 0) {
        for($i = $x; $i <= $map["maxx"]; $i++){
            if(array_key_exists("$row:$i", $map) && $map["$row:$i"] == "#") {
                $right = $i;
                return [
                    "enclosed" => true,
                    "left" => $left,
                    "right" => $right
                ];
            }
        }
    }
    return ["enclosed" => false];
}

function is_all_water_or_clay($map, $row, $left, $right) {
    for($i = $left; $i <= $right; $i++){
        if(!array_key_exists("$row:$i", $map)){
            return false;
        }
        if ($map["$row:$i"] == "|") {
            return false;
        }
    }
    return true;
}

function mark_range(&$map, $s, $y, $left, $right) {
    $reschedule = [];
    for($i = $left; $i <= $right; $i++){
        // check if already with water
        // is it dripping from above?
        $up = $y-1;
        if($up >= $map["miny"] && array_key_exists("$up:$i", $map) && $map["$up:$i"] == "|"){
            if($up == 282) {
                print(":".$map["$up:$i"]);
            }
            $reschedule[] = ["x" => $i, "y" => $up];
        }
        $map["$y:$i"] = $s;
    }
    return $reschedule;
}


function full_all_available(&$map, $x) {
    $q = [];
    $visited = [];

    $q[] = [
        "x" => $x,
        "y" => $map["miny"]
    ];

    while (count($q)) {
        $p = array_shift($q);
        $x = $p["x"];
        $y = $p["y"];
        $result = probe_row($map, $p["y"], $p["x"]);
        $enc = $result["enclosed"];
        if (!array_key_exists("$y:$x", $map)){
            $map["$y:$x"] = "|";
        }else if($map["$y:$x"] != "|"){
            continue;
        }
        $visited["$y:$x"] = true;
        if ($result["enclosed"]){
            $r = is_all_water_or_clay($map, $p["y"] + 1, $result["left"], $result["right"]);
            
            if ($p["y"] + 1 <= $map["maxy"] && is_all_water_or_clay($map, $p["y"] + 1, $result["left"], $result["right"])) {
                $reschedule = mark_range($map, "~", $p["y"], $result["left"]+1, $result["right"]-1);
                // then schedule the previous point to be checked again
                
                if ($p["y"] - 1 >= $map["miny"]){
                    $q[] = [
                        "x" => $p["x"],
                        "y" => $p["y"] - 1
                    ];
                    foreach ($reschedule as $r) {
                        $q[] = $r;
                    }
                    continue;
                }

            }
        }
        $down = $p["y"] + 1;
        $left = $p["x"] - 1;
        $right = $p["x"] + 1;
        
        
        if($down <= $map["maxy"] && (!array_key_exists("$down:$x", $map) || $map["$down:$x"] == "|" )){
            // go down
            $q[] = ["x" => $x, "y" => $down];
        }else {
            if ($down > $map["maxy"]) {
                continue;
            }
            // go left and right
            if ($left >= $map["minx"] && !array_key_exists("$y:$left", $map)){
                // go left
                $q[] = ["x" => $left, "y" => $y];
            }
            if ($right <= $map["maxx"] && !array_key_exists("$y:$right", $map)){
                // go right
                $q[] = ["x" => $right, "y" => $y];
            }
        }
        
    }

    return $map;
}


function count_all_water($map) {
    $water = 0;
    foreach( $map as $k => $v ) {
        if ($v == "|" || $v == "~"){
            $water++;
        }
    }

    return $water;
}

function count_all_retained_water($map) {
    $water = 0;
    foreach( $map as $k => $v ) {
        if ($v == "~"){
            $water++;
        }
    }

    return $water;
}

function print_map($map, $x=null, $y=null) {
    for ($i = $map["miny"]; $i <= $map["maxy"]; $i++){
        $r = $i + $map["miny"];
        printf("%5d: ", $r);
        for ($j = $map["minx"]; $j <= $map["maxx"]; $j++){
            if($x != null && $y != null && $x == $j && $y == $i){
                print("X");
            }else if(array_key_exists("$i:$j", $map)){
                $v = $map["$i:$j"];
                print("$v");
            }else{
                printf(".");
            }
        }
        print("\n");
    }
    print("\n\n");
}

$readings = read_input("input");
$map = get_clay_map($readings);

$map = full_all_available($map, 500);
print_map($map);

$part1 = count_all_water($map);
print("Part 1: $part1\n");

$part2 = count_all_retained_water($map);
print("Part 2: $part2\n");

?>