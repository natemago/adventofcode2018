import fs = require("fs");
class Instruction{
    constructor(op: string, a:number, b:number, c:number){

    }
}
class Computer {
    private PC:number = 0;
    private registers:Array<number>;
    private program:Array<any>;
    private ip:number;
    private seen:any = {};
    private part1:number = null;
    private cycle:Array<number> = [];

    constructor(program:Array<any>, registers:Array<number>, ip:number){
        this.PC = 0;
        this.ip = ip;
        this.registers = registers;
        this.program = program;
        this.cycle = [];
    }

    addr(instr:any){
        this.registers[instr.c] = this.registers[instr.a] + this.registers[instr.b];
    }

    addi(instr:any){
        this.registers[instr.c] = this.registers[instr.a] + instr.b;
    }

    mulr(instr:any){
        this.registers[instr.c] = this.registers[instr.a] * this.registers[instr.b];
    }

    muli(instr:any){
        this.registers[instr.c] = this.registers[instr.a] * instr.b;
    }

    banr(instr:any){
        this.registers[instr.c] = this.registers[instr.a] & this.registers[instr.b];
    }

    bani(instr:any){
        this.registers[instr.c] = this.registers[instr.a] & instr.b;
    }

    borr(instr:any){
        this.registers[instr.c] = this.registers[instr.a] | this.registers[instr.b];
    }

    bori(instr:any){
        this.registers[instr.c] = this.registers[instr.a] | instr.b;
    }

    setr(instr:any){
        this.registers[instr.c] = this.registers[instr.a];
    }

    seti(instr:any){
        this.registers[instr.c] = instr.a;
    }

    gtir(instr:any){
        if(instr.a > this.registers[instr.b]){
            this.registers[instr.c] = 1
        }else{
            this.registers[instr.c] = 0;
        }
    }

    gtri(instr:any){
        if(this.registers[instr.a] > instr.b){
            this.registers[instr.c] = 1
        }else{
            this.registers[instr.c] = 0;
        }
    }

    gtrr(instr:any){
        if(this.registers[instr.a] > this.registers[instr.b]){
            this.registers[instr.c] = 1
        }else{
            this.registers[instr.c] = 0;
        }
    }

    eqir(instr:any){
        if(instr.a == this.registers[instr.b]){
            this.registers[instr.c] = 1
        }else{
            this.registers[instr.c] = 0;
        }
    }

    eqri(instr:any){
        if(this.registers[instr.a] == instr.b){
            this.registers[instr.c] = 1
        }else{
            this.registers[instr.c] = 0;
        }
    }

    eqrr(instr:any){
        if(!this.part1){
            console.log('Part 1: ', this.registers[4]);
            this.part1 = this.registers[4];
        }
        console.log(this.cycle.length, this.registers[4]);
        if(instr.a == 4 && instr.b == 0){
            if(this.seen[this.registers[4]]){
                console.log("Part 2: ", this.cycle[this.cycle.length-1]);
                throw Error("BOOM");
            }
            this.seen[this.registers[4]] = true;
            this.cycle.push(this.registers[4]);
        }
        if(this.registers[instr.a] == this.registers[instr.b]){
            this.registers[instr.c] = 1
        }else{
            this.registers[instr.c] = 0;
        }
    }


    executeInstruction():boolean{
        this.PC = this.registers[this.ip];
        if(this.PC < 0 || this.PC >= this.program.length) {
            console.log("<<HALT>>");
            return true;
        }
        let instr = this.program[this.PC];
        //console.log("   >>", instr);
        this[instr.op](instr);
        this.PC = this.registers[this.ip];
        this.PC++;
        this.registers[this.ip] = this.PC;
        return false;
    }

    execute(maxTicks:number){
        var n = 0;
        var seen = {};
        while(true){
            if(this.executeInstruction()){
                // halted
                return n+1;
            }
            if(n > 1000 ){
                seen[this.registers[4]%16777215] = true;
            }
            
            n++;
            if(n >= maxTicks){
                break;
            }
        }
        return n;
    }

    printSeen(){
        var s = [];
        for(let val in this.seen){
            s.push(parseInt(val));
        }
        s.sort(function(a:number,b:number){
            return a-b;
        });
        for(let i = 0; i < s.length; i++){
            console.log(s[i]);
        }
    }
}

function loadInput(file:string):any{
    let content = fs.readFileSync(file, 'UTF-8').split('\n');
    var program = [];
    for(var i = 1; i < content.length; i++){
        if(content[i].trim() == ""){
            continue;
        }
        let ip = content[i].split(' ');
        program.push({
            op: ip[0].trim(),
            a: parseInt(ip[1]),
            b: parseInt(ip[2]),
            c: parseInt(ip[3])
        });
    }
    return {
        ip: parseInt(content[0].split(' ')[1]),
        program: program
    }
}


function solve(input:any){
    let N = 10000000000; // 10 trilion
    let c = new Computer(input.program, [1,0,0,0,0,0], input.ip);
    let n = c.execute(N);
    console.log("Not found, we need to go deeper.")
}

solve(loadInput("input"));