var TYPES = ['.',   // rocky
             '=',   // wet
             '|'];  // narrow
var POSSIBLE_TOOLS = {
    0: ['T', 'C'],
    1: ['N', 'C'],
    2: ['N', 'T']
}

function getGeologicIndex(x,y, cave, target){
    if(x == 0 && y == 0){
        return 0;
    }
    if(x == target.x && y == target.y){
        return 0;
    }
    if(y == 0){
        return x*16807;
    }
    if(x == 0){
        return y*48271;
    }
    return cave[y][x-1] * cave[y-1][x];
}

function getErosionIndex(x,y, cave, target, depth){
    return (getGeologicIndex(x,y,cave, target)  + depth)% 20183;
}

function getCellType(x,y,cave,target, depth){
    return getErosionIndex(x,y,cave,target, depth) % 3;
}

function getCaveMap(target, depth){
    var map = [];
    for (var y = 0; y <= target.y+40; y++){
        var row = [];
        map.push(row);
        for (var x = 0; x <= target.x*6; x++){
            let val = getErosionIndex(x, y, map, target, depth);
            row.push(val);
        }
    }
    return map;
}

function printMap(map){
    for(var i = 0; i < map.length; i++){
        console.log(map[i].map((t) => TYPES[t%3]).join('') );
    }
}

function getAvailableLocations(x,y, map){
    return [[x, y+1], [x+1, y], [x-1, y], [x, y-1]].filter((p) => {
        return p[0] >= 0 && p[0] < map[0].length && p[1] >=0 && p[1] < map.length;
    }).map((p) => {
        return {x: p[0], y: p[1]};
    });
}

function getAllPossibleMoves(p, map, target){
    let locations = getAvailableLocations(p.x, p.y, map);
    var moves = [];

    locations.forEach((location) => {
        let locType = map[location.y][location.x] % 3;
        let possibleTools = POSSIBLE_TOOLS[locType];
        let currentLocationPossibleTools = POSSIBLE_TOOLS[map[p.y][p.x]%3];
        if(location.x == target.x && location.y == target.y) {
            possibleTools = ['T']; // always arrive with torch.
        }
        
        possibleTools.forEach((tool) => {
            if(currentLocationPossibleTools.indexOf(tool)>=0){
                moves.push({x: location.x, y: location.y, tool: tool});
            }
        });
    });
    return moves;
}

function asKey(p){
    return ''+p.x + ':' + p.y + ':' + p.tool;
}


function costEstimate(p1, p2){
    return (Math.abs(p1.x - p2.x) + Math.abs(p1.y - p2.y));
}

function calculateMinutes(s, t, map){
    var mins = 0;
    if(s.x != t.x || s.y != t.y){
        mins++;
    }
    if(s.tool != t.tool){
        mins+=7; // 7 minutes to change tool + 1 to move
    }
    //console.log(s,t, mins);
    return mins;
}

function isIn(p, set){
    for(var i = 0; i < set.length; i++){
        if(p.x == set[i].x && p.y == set[i].y && p.tool == set[i].tool){
            return true;
        }
    }
    return false;
}

function getOrInf(key, score){
    let v = score[key];
    if (v === undefined){
        return Infinity;
    }
    return v;
}

function findShortestPathAstar(start, target, map){
    var closedSet = {};
    var openSet = [start];
    var cameFrom = {};
    var gScore = {};
    var fScore = {};
    gScore[asKey(start)] = 0;
    fScore[asKey(start)] = costEstimate(start, target);
    var path = [];
    var cnt = 0;
    while(openSet.length) {
        openSet.sort(function(a,b){
            let fa = getOrInf(asKey(a), fScore);
            let fb = getOrInf(asKey(b), fScore);
            return fa - fb;
        });
        let current = openSet[0];
        if(current.x == target.x && current.y == target.y) {
            // reached the man in the cave
            var c = current;
            path.push(c);
            while(cameFrom[asKey(c)]){
                c = cameFrom[asKey(c)];
                path.push(c);
            }
            return {mins: gScore[asKey(current)], path: path};
        }
        openSet = openSet.slice(1);
        closedSet[asKey(current)] = current;

        var neighbours = getAllPossibleMoves(current, map, target);
        for(var i = 0; i < neighbours.length; i++){
            let neigbour = neighbours[i];
            if(closedSet[asKey(neigbour)]){
                continue; // already visited
            }
            tScore = getOrInf(asKey(current), gScore) + calculateMinutes(current, neigbour, map);

            if (!isIn(neigbour, openSet)) {
                openSet.push(neigbour);
            }else if (tScore > getOrInf(asKey(neigbour), gScore)){
                // there is a better path
                continue;
            }
            cameFrom[asKey(neigbour)] = current;
            gScore[asKey(neigbour)] = tScore;
            let nscore = getOrInf(asKey(neigbour), gScore) + costEstimate(neigbour, target);
            fScore[asKey(neigbour)] =  nscore;
        }
        if(cnt%10000 == 0){
            console.log("\t: ", openSet.length, ' in queue. Total of ', cnt, 'iterations.');
        }
        cnt++;
    }

}


function part1(map){
    var s = 0;
    for (var i = 0; i < map.length; i++){
        for(var j = 0; j < map[i].length; j++){
            s += map[i][j]%3;
        }
    }
    return s;
}

function part2(map, target) {   
    let t1 = findShortestPathAstar({x: 0, y: 0, tool: 'T'}, target, map);
    printMapWithPath(map, t1.path);
    var n = t1.path.length - 2;
    var s = 0;
    var tool = 'T';
    while(n >= 0){
        let c = t1.path[n];
        if(c.tool != tool){
            s += 7;
        }
        s += 1;
        n--;
        tool = c.tool;
    }
    console.log('Total: ', s, ', Walking: ', t1.path.length - 1, '; Changing gear: ', s- (t1.path.length - 1));
    return s;
}


function printMapWithPath(map, path){
    var sm = [];
    map.forEach((row)=>{
        sm.push(row.map((c) => {
            return TYPES[c%3];
        }));
    });
    path.forEach((p) => {
        sm[p.y][p.x] = p.tool;
    });

    sm.forEach((row) => {
        console.log(row.join(''));
    });
}

console.log("Part 1: ", part1(getCaveMap({x: 10, y: 785}, 5616)));
console.log("Part 2: ", part2(getCaveMap({x: 10, y: 785}, 5616), {x: 10, y: 785}))