function newCart(x,y, s, cart_id, carts) {
    carts[cart_id, "pos", "x"] = x
    carts[cart_id, "pos", "y"] = y
    
    carts[cart_id, "action"] = 0 # 0 - left, 1 - forward, 2 - right

    if (s == "<"){
        carts[cart_id, "dir", "x"] = -1
        carts[cart_id, "dir", "y"] = 0
    }else if (s == "^") {
        carts[cart_id, "dir", "x"] = 0
        carts[cart_id, "dir", "y"] = -1
    }else if (s == "v"){
        carts[cart_id, "dir", "x"] = 0
        carts[cart_id, "dir", "y"] = 1
    }else if (s == ">"){
        carts[cart_id, "dir", "x"] = 1
        carts[cart_id, "dir", "y"] = 0
    }else{
        print "ERROR " x ", " y ", " s
    }
    print " > new cart: D(" carts[cart_id, "dir", "x"] "," carts[cart_id, "dir", "y"] "); POS(", carts[cart_id, "pos", "x"] "," carts[cart_id, "pos", "y"] ")"
}

function rotateLeft(cart_id, carts,         x,y) {
    x = carts[cart_id, "dir", "x"]
    y = carts[cart_id, "dir", "y"]
    carts[cart_id, "dir", "x"] =   y #carts[cart_id, "dir", "y"]
    carts[cart_id, "dir", "y"] =  -x #carts[cart_id, "dir", "x"]
}

function rotateRight(cart_id, carts,         x,y) {
    x = carts[cart_id, "dir", "x"]
    y = carts[cart_id, "dir", "y"]
    carts[cart_id, "dir", "x"] = -y  #carts[cart_id, "dir", "y"]
    carts[cart_id, "dir", "y"] =  x   #carts[cart_id, "dir", "x"]
}


function doTheseCollide(cartA, cartB, carts) {
    if (carts[cartA,"pos","x"] == carts[cartB, "pos", "x"] && carts[cartA,"pos","y"] == carts[cartB, "pos", "y"]){
        return 1
    }
    return 0
}

function moveOne(cid, carts, rails,                        c,px,py,cx,cy,dx,dy,pd) {
    c = rails[carts[cid, "pos", "x"], carts[cid, "pos", "y"]]
    #print "    => moving " cid "; currently at: " c
    
    px = carts[cid, "prev", "x"]
    py = carts[cid, "prev", "y"]
    cx = carts[cid, "pos", "x"]
    cy = carts[cid, "pos", "y"]
    dx = carts[cid, "dir", "x"]
    dy = carts[cid, "dir", "y"]
    if (!dx){
        dx = 0
    }
    if (!dy){
        dy = 0
    }
    #print "               x,y=" cx","cy
    #print "                     dir: " dx "," dy

    pd=dx","dy
    if (c == "/"){
        if (pd == "0,1") {
            dx=-1
            dy=0
        }else if(pd == "0,-1"){
            dx=1
            dy=0
        }else if(pd == "1,0"){
            dx=0
            dy=-1
        }else{
            dx=0
            dy=1
        }
    }
    if (c == "\\"){
        if (pd == "0,1") {
            dx=1
            dy=0
        }else if(pd == "0,-1"){
            dx=-1
            dy=0
        }else if(pd == "1,0"){
            dx=0
            dy=1
        }else{
            dx=0
            dy=-1
        }
    }
    #print "                      > final dir: " dx "," dy
    carts[cid, "dir", "x"] = dx
    carts[cid, "dir", "y"] = dy
    carts[cid, "prev", "x"] = cx
    carts[cid, "prev", "y"] = cy
    cx = cx + dx
    cy = cy + dy
    carts[cid, "pos", "x"] = cx
    carts[cid, "pos", "y"] = cy
}

function moveNext(cid, carts, rails,              c,action){
    c = rails[carts[cid, "pos", "x"], carts[cid, "pos", "y"]]
    if (c == " " || c == ""){
        print "ERROR "cid
        exit 1
    }
    #print " :: move " cid
    if (c == "+") {
        # make turn decision
        action = carts[cid, "action"]
        if (action == 0){
            #print " :: -> turn left"
            rotateLeft(cid, carts)
        }else if (action == 2) {
            rotateRight(cid, carts)
            #print " :: -> turn right"
        }
        carts[cid, "action"] = (action + 1) % 3
    }
    moveOne(cid, carts, rails)
}

function hasCart(x,y, carts, cartsLen,                i){
    for (i = 0; i < cartsLen; i++){
        if (carts[i, "pos", "x"] == x && carts[i, "pos", "y"] == y){
            return (i+1)
        }
    }
    return 0
}

function printCarts(carts, cartsLen, rails, width,height,                i,j,row) {
    for (i = 0; i < height; i++){
        row="["
        for (j=0; j < width; j++){
            if (hasCart(j, i, carts, cartsLen)){
                row=row "" (hasCart(j, i, carts, cartsLen)-1)
            }else{
                row=row "" rails[j, i]
            }
        }
        print row "]"
    }
}

function sort_carts(i1,c1,i2,c2){
    # carts is global
    if (carts[cartsi[i1], "pos", "y"] == carts[cartsi[i2], "pos", "y"]){
        return carts[cartsi[i1], "pos", "x"] - carts[cartsi[i2], "pos", "x"]
    }
    return carts[cartsi[i1], "pos", "y"] - carts[cartsi[i2], "pos", "y"]
}

function printarr(arr, sep,                                            result, i){
    result = arr[0]
    for (i=1; i<length(arr);i++){
        result=result""sep""arr[i]
    }
    print result
}

function removeat(arr, i, result,                          k,kk){
    kk = 0
    for (k in arr){
        if (k != i){
            result[kk] = arr[k]
            kk++
        }
    }
}


BEGIN {

    curr_line = 0
    curr_cart = 0
    width = 0
    height = 0
    carts_number = 0
}
/.+/ {
    split($0, line, "")
    for (i = 0; i < length(line); i++){
        if (line[i] == "^" || line[i] == "v") {
            rails[i, curr_line] = "|"
        }else if (line[i] == "<" || line[i] == ">") {
            rails[i, curr_line] = "-"
        }else{
            rails[i, curr_line] = line[i]
        }
        if (line[i] == "<" || line[i] == ">" || line[i] == "^" || line[i] == "v") {
            newCart(i, curr_line, line[i], curr_cart, carts)
            cartsi[curr_cart] = curr_cart
            curr_cart += 1
        }
    }
    curr_line += 1
    if (length(line) > width){
        width = length(line)
    }
}
END {
    height = curr_line
    carts_number = curr_cart
    print curr_cart " carts."
    print curr_line " lines."
    print "Start driving"

    pajo[0] = 1
    pajo[1] = 1
    pajo[2] = 3
    print "P"length(pajo)
    delete pajo[1]
    print "P"length(pajo)

    PART1 = 0

    count = 0
    collide = 0
    N=4
    while (1) {
        
        #print "=============================="
        #printCarts(carts, curr_cart, rails, width, height)

        # now, sort
        asort(cartsi, sorted_cartsi, "sort_carts")
        #print "L:"sorted_cartsi[2]
        #printarr(cartsi,", ")

        delete toberemoved
        tbrc = 0
        for (k = 0; k < length(cartsi); k++) {
            sc = sorted_cartsi[(k+1)]
            moveNext(sc, carts, rails)
            for (i = 0; i < (length(cartsi)-1); i++) {
                for (j = i+1; j < length(cartsi); j++) {
                    if (doTheseCollide(cartsi[i], cartsi[j], carts)) {
                        print "cartsi="length(cartsi)
                        collide = 1
                        colX = carts[cartsi[i], "pos", "x"]
                        colY = carts[cartsi[i], "pos", "y"]
                        print "Colliding: " cartsi[i] " with " cartsi[j] " @ " count

                        if(PART1){
                            break
                        }
                        # part 2, remove the crashing cars
                        if (!toberemoved[i+1]){
                            print "add "i
                            toberemoved[i+1] = i+1
                        }
                        if (!toberemoved[j+1]){
                            toberemoved[j+1] = j+1
                        }
                    }
                }
                # if(collide){
                #     break
                # }
            }
        }

        if (!PART1){

            if(length(toberemoved)){
                printarr(toberemoved, "/")
                for(i in toberemoved){
                    if (toberemoved[i]) {
                        print "delete " (i-1) ":" (toberemoved[i]-1)
                        delete cartsi[(toberemoved[i] - 1)]
                    }
                    
                }
                _c = 0
                for (i in cartsi){
                    _n[_c] = cartsi[i]
                    _c++
                }
                delete cartsi
                for (i in _n){
                    cartsi[i] = _n[i]
                }
                printarr(cartsi,"|")
                # if (hasbeenhere){
                #     exit 1
                # }else{
                #     hasbeenhere=1
                # }
                #exit 0
               
            }

            if (length(cartsi) == 1){
                print "Final cart at: " carts[cartsi[0]] "," carts[cartsi[0]]
                exit 0
            }
        }
        

        if (collide && PART1) {
            break
        }

        # print count
        # printCarts(carts, curr_cart, rails, width, height)
        # print "=============================="
        # 
        
        # count++
        # if (count >= 25){
        #     break
        # }
    }
    printCarts(carts, curr_cart, rails, width, height)
    #print "=============================="
    print "Collision at: " (colX-1) "," colY 
}