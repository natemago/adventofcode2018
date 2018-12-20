#include<stdio.h>
#include<stdlib.h>
#include<string.h>


const int DOOR = 2;
const int ROOM = 1;

typedef struct Node { 
    int c_number;
    struct Node **children;
    struct Node *parent;
    char *payload;
} Node;


typedef struct AST {
    struct Node *root;
} AST;

Node *new_node(){
    Node *node = malloc(sizeof(Node));
    node->c_number = 0;
    node->payload = NULL;
    node->children = NULL;
    return node;
}


void append_child(Node *root, Node *child) {
    Node **children = malloc((root->c_number + 1 ) *sizeof(Node*));
    for(int i = 0; i < root->c_number; i++){
        children[i] = root->children[i];
    }
    children[root->c_number] = child;
    root->c_number++;
    if (root->children != NULL){
        free(root->children);
    }
    root->children = children;
    child->parent = root;
}


void parse(char *input, Node* parent, Node* node){
    printf("   :: P\n");
    char buff [2048];
    int p_count = 0;
    char curr = input[0];
    if (curr == 0 || curr == '$'){
        return;
    }
    printf("   :: ...\n");
    while(curr != '|' && curr != '(' && curr != ')' && curr != 0 && curr != '$') {
        buff[p_count] = curr;
        p_count++;
        curr = input[p_count];
    }

    // append the payload
    if (p_count > 0){
        printf("      :: payload (alloc=%d)\n", (p_count + 1));
        node->payload = malloc(p_count + 1);
        for(int i = 0; i < p_count; i++){
            node->payload[i] = buff[i];
        }
        node->payload[p_count] = 0;
    }
    printf("    :: about to append\n");
    append_child(parent, node);
    input = input + p_count + 1;
    printf("       :: about to recurse\n");
    if (curr == '(') {
        // child node
        Node *child = new_node();
        parse(input, node, child);
    }else if (curr == '|') {
        // sibling
        Node *sibling = new_node();
        parse(input, parent, sibling);
        if(input[0] == ')'){
            printf("skip this whole group");
            for(int i = 0; i < parent->parent->c_number; i++) {
                parse(input+1, parent->parent->children[i], sibling);
            }
        }
    }else{
        // end of input not reached, another child node.
        
        Node *child = new_node();
        printf("    :: ) or non empty\n");
        for(int i = 0; i < parent->c_number; i++){
            //Node *child = new_node();
            printf("   -- append\n");
            parse(input, parent->children[i], child);
        }
        
        if (input[0] == '|'){
            for(int i = 0; i < parent->parent->c_number; i++){
                printf(" :: upper kid\n");
                parse(input+1, parent->parent->children[i], child);
            }
            
        }
    }
    printf("        :: done\n");
}




AST *parse_ast(char *input){
    AST *tree = malloc(sizeof(AST));

    Node *root = new_node();
    tree->root = root;

    parse(input, root, new_node());

    return tree;
}


char* get_longest_path(Node* node) {
    char *path;
    printf("(");
    if(node->payload != NULL){
        printf("[%s]", node->payload);
    }else{
        printf("[]");
    }
    
    if(node->c_number > 0) {
        for(int i = 0; i < node->c_number; i++){
            get_longest_path(node->children[i]);
            
        }
    }
    printf(")");
    return path;
}

int ** empty_matrix(){
    int **matrix = malloc(2048*sizeof(int*));
    for(int i = 0; i < 2048; i++){
        int *row = malloc(2048*(sizeof(int)));
        for(int j = 0; j < 2048; j++) {
            row[j] = 0;
        }
        matrix[i] = row;
    }
    return matrix;
}

void walk(int x, int y, int **matrix, Node *node){
    if(node->payload != NULL){
        for(int i = 0;;i++){
            char c = node->payload[i];
            if (c == 0){
                break;
            }
            if(c == 'W'){
                x--;
                matrix[y][x] = DOOR;
                x--;
                matrix[y][x] = ROOM;
            }else if(c == 'N'){
                y--;
                matrix[y][x] = DOOR;
                y--;
                matrix[y][x] = ROOM;
            }else if(c == 'E'){
                x++;
                matrix[y][x] = DOOR;
                x++;
                matrix[y][x] = ROOM;
            }else if(c == 'S'){
                y++;
                matrix[y][x] = DOOR;
                y++;
                matrix[y][x] = ROOM;
            }else{
                printf("WOOPS, unknown direction: %c\n", c);
                exit(1);
            }
            if(x < 0 || x > 2047 || y < 0 || y > 2047){
                printf(" OUT OF BOUNDS: %d,%d\n",x,y);
                exit(1);
            }
            
        }
    }
    if(node->c_number > 0){
        for(int i = 0; i < node->c_number; i++){
            walk(x,y, matrix, node->children[i]);
        }
    }
}

void bounds(int *x1, int *x2, int *y1, int *y2, int **matrix){
    int x = 2048, xx = -1, y = 2048, yy = -1;

    for(int i = 0; i < 2048; i++){
        for(int j = 0; j< 2048; j++){
            if(matrix[j][i] > 0){
                if(j < y){
                    y = j;
                }
                if(j > yy){
                    yy = j;
                }
                if(i < x){
                    x = i;
                }
                if(i > xx){
                    xx = i;
                }
            }
        }
    }

    *x1=x;
    *x2=xx;
    *y1=y;
    *y2=yy;
}

int door_between(int x, int y, int xx, int yy, int **m) {
    int _x = x, _y = y;
    if (xx != x){
        _x = xx > x ? x+1: x-1;
    }else{
        _y = yy > y ? x+1: x-1;
    }
    return m[_y][_x] == DOOR;
}

void walk_through_doors(int **m, int**dists, int x, int y){
    int poss[4][2] = {
                {x, y-2},
        {x-2, y},           {x+2, y},
                {x, y+2},           };
    
    int c = dists[y][x];
    for (int i = 0; i < 4; i++) {
        int cx = poss[i][0];
        int cy = poss[i][1];

        if(cx < 0 || cx > 2047 || cy < 0 || cy > 2047 || (cx == 1023 && cy == 1023)) {
            continue;
        }
        if(m[cy][cx] > 0 && door_between(x,y, cx,cy, m)){
            int cd = dists[cy][cx];
            if(cd == 0 ){
                dists[cy][cx] = c + 1;
                walk_through_doors(m, dists, cx, cy);
            }else{
                if(cd > c){
                    if(cd - c > 1){
                        dists[cy][cx] = c + 1;
                        walk_through_doors(m, dists, cx, cy);
                    }
                }else if (cd < c) {
                    if(c - cd > 1){
                        dists[y][x] = cd + 1;
                        walk_through_doors(m, dists, x, y);
                    }
                }
            }
        }
    }
}



void print_map(int x, int xx, int y, int yy, int**m, const char* sep){
    for(int i = y; i <= yy; i++){
        for(int j = x; j <= xx; j++){
            printf("%3d%s", m[i][j], sep);
        }
        printf("\n");
    }
}


void print_map_char(int x, int xx, int y, int yy, int**m){
    for(int i = y; i <= yy; i++){
        for(int j = x; j <= xx; j++){
            if(m[i][j] == DOOR){
                printf("|");
            }else if(m[i][j] == ROOM) {
                printf(".");
            }else{
                printf("#");
            }
        }
        printf("\n");
    }
}

char* load_input(char *filename) {
    FILE *f = fopen(filename, "r");
    fseek(f, 0, SEEK_END);
    long size = ftell(f);
    char *buff = malloc(size+1);
    fseek(f, 0, SEEK_SET);
    fread(buff, size, 1, f);
    fclose(f);
    buff[size] = 0;

    for(int i = 0; i < size - 3; i++){
        buff[i] = buff[i+1];
    }
    buff[size-3] = 0;
    return buff;
}

int get_max(int **m){
    int max = 0;
    for(int i = 0; i < 2048; i++){
        for(int j = 0; j < 2048; j++){
            if(m[i][j] > max){
                max = m[i][j];
            }
        }
    }
    return max;
}

int main(){
    char *input = load_input("input.test");
    printf(":: input loaded\n");
    printf("%s\n", input);
    AST *tree = parse_ast(input);
    printf(":: tree parsed\n");
    get_longest_path(tree->root);
    int **m = empty_matrix();
    int **dists = empty_matrix();
    walk(1023, 1023, m, tree->root);
    printf(":: input walked\n");
    int minx, miny, maxx, maxy;
    bounds(&minx, &maxx, &miny, &maxy, m);
    printf("Bounds: %d,%d,%d,%d\n",minx,maxx,miny,maxy);
    print_map_char(minx, maxx, miny, maxy, m);
    walk_through_doors(m, dists, 1023, 1023);
    print_map(minx, maxx, miny, maxy, dists, " ");
    printf("Part 1: %d\n", get_max(dists));
}