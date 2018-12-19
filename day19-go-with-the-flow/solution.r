loadInput <- function(inpfile) {
    inp <- read.delim(inpfile, header=FALSE, sep=" ")
    return(inp)
}

printf <- function(...) print(sprintf(...))

executeProgram <- function(program) {
    print(program[1,1])
    registers <- rep(0, 6)
    
    pa = 0
    PC = 2 # 1-based, oh well
    ip = program[1,2]
    PL = nrow(program)
    cnt = 0
    while (TRUE) {
        # fetch
        if  (PC < 1 || PC > PL ){
            print("<<HALT>>")
            print(registers)
            break
        }
        
        
        instr <- program[PC,]
        op = instr[[1]]
        a = instr[[2]]
        b = instr[[3]]
        c = instr[[4]]
        registers[ip + 1] = PC - 2
        
        
        if (op == "addr" ) {
            registers[c + 1] = registers[a + 1] + registers[b + 1]
        }else if (op == "addi"){
            registers[c + 1] = registers[a + 1] + b
        }else if (op == "mulr"){
            registers[c + 1] = registers[a + 1] * registers[b + 1]
        }else if (op == "muli"){
            registers[c + 1] = registers[a+1] * b
        }else if (op == "banr"){
            registers[c + 1] = registers[a+1] & registers[b+1]
        }else if (op == "bani"){
            registers[c + 1] = registers[a+1] & b
        }else if (op == "borr"){
            registers[c + 1] = registers[a+1] | registers[b+1]
        }else if (op == "bori"){
            registers[c + 1] = registers[a+1] | b
        }else if (op == "setr"){
            registers[c+1] = registers[a+1]
        }else if (op == "seti"){
            registers[c+1] = a
        }else if (op == "gtir"){
            if(a > registers[b+1]){
                registers[c+1] = 1
            }else{
                registers[c+1] = 0
            }
        }else if (op == "gtri"){
            if(registers[a+1] > b){
                registers[c+1] = 1
            }else{
                registers[c+1] = 0
            }
        }else if (op == "gtrr"){
            if(registers[a+1] > registers[b+1]){
                registers[c+1] = 1
            }else{
                registers[c+1] = 0
            }
        }else if (op == "eqir"){
            if(a == registers[b+1]){
                registers[c+1] = 1
            }else{
                registers[c+1] = 0
            }
        }else if (op == "eqri"){
            if(registers[a+1] == b){
                registers[c+1] = 1
            }else{
                registers[c+1] = 0
            }
        }else if (op == "eqrr"){
            if(registers[a+1] == registers[b+1]){
                registers[c+1] = 1
            }else{
                registers[c+1] = 0
            }
        }else {
            print("[WRONG INSTRUCTION]")
            print(op)
            break
        }
        # #if ((cnt %% 100000) == 0){
        # if (cnt == 200){
        #     #break
        #     #printf("(%d)%d", cnt, PC)
        #     #print(registers)
        # }
        # cnt = cnt + 1

        PC = registers[ip + 1] + 2
        PC = PC + 1
        if (registers[1] != pa){
            printf(" ::: %d changed to %d", pa, registers[1])
            print(registers)
        }
        pa = registers[1]
    }
}

executeProgram(loadInput("input"))
# part 2
# I figured that the procedure calculates the sum of all divisors of some number N (including 1 and N)
# I got the number for part 2 from the registers itself: N=10551425
# All prime divisors of 10551425 are 5,5 and 422057
# All divisors of N thus are: 1, 5, (5*5), 422057, (5*422057), and 10551425
# The sum is: 13083798