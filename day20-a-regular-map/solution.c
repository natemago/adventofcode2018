#include<stdio.h>
#include<stdlib.h>
#include<string.h>


const int DOOR = 2;
const int ROOM = 1;


typedef struct Point {
    int x;
    int y;
} Point;

typedef struct Stack {
    Point *point;
    struct Stack *next;
} Stack;


Point *new_point(int x, int y) {
    Point *point = malloc(sizeof(Point));
    point->x = x;
    point->y = y;
    return point;
}

Stack *push(Stack *stack, Point *point){
    Stack *frame = malloc(sizeof(Stack));
    frame->point = point;
    if(stack != NULL) {
        frame->next = stack;
    }else{
        frame->next = NULL;
    }
    return frame;
}

Stack *pop(Stack *stack) {
    if(stack == NULL){
        printf("Pop from empty stack\n");
        exit(1);
    }
    Stack *c = stack;
    stack = stack->next;
    free(c);
    return stack;
}

int ** empty_matrix(int width, int height){
    int **matrix = malloc(height*sizeof(int*));
    for(int i = 0; i < height; i++){
        int *row = malloc(width*(sizeof(int)));
        for(int j = 0; j < width; j++) {
            row[j] = 0;
        }
        matrix[i] = row;
    }
    return matrix;
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

    for(int i = 0; i < size - 1; i++){
        buff[i] = buff[i+1];
    }
    buff[size-2] = 0;
    buff[size-1] = 0;
    return buff;
}

void walk_input(int **m, char *input, int sx, int sy){
    Point *curr = new_point(sx, sy);
    Stack *stack = push(stack, curr);
    while(1) {
        char c = *input;
        if(c == 0){
            break;
        }
        if(c == '(') {
            stack = push(stack, curr);
        }else if( c == ')' ){
            stack = pop(stack);
        }else if(c == '|' ){
            curr = stack->point;
        }else{
            Point *p = new_point(curr->x, curr->y);
            if( c == 'N') {
                p->y--;
            }else if(c == 'S'){
                p->y++;
            }else if(c == 'E'){
                p->x++;
            }else if(c == 'W'){
                p->x--;
            }else{
                printf("Uknown: %c\n", c);
                exit(1);
            }
            int dist = m[curr->y][curr->x];
            
            if(m[p->y][p->x] == 0){
                m[p->y][p->x] = dist+1;
            }
            curr = p;
        }
        input++;
    }
}

int get_max(int **m, int width, int height){
    int max = 0;
    for(int i = 0; i < height; i++){
        for(int j = 0; j < width; j++){
            if(m[i][j] > max){
                max = m[i][j];
            }
        }
    }
    return max;
}

int get_count_gte(int **m, int gte, int width, int height){
    int count = 0;
    for(int i = 0; i < height; i++){
        for(int j = 0; j < width; j++){
            if(m[i][j] >= gte){
                count++;
            }
        }
    }
    return count;
}

int main() {
    char *input = load_input("input");
    int **m = empty_matrix(4096, 4096);
    walk_input(m, input, 2048, 2048);
    printf("Part 1: %d\n", get_max(m, 4096, 4096));
    printf("Part 2: %d\n", get_count_gte(m, 1000, 4096, 4096));
    return 0;
}