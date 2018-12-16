local Computer = {}
Computer.__index = Computer

function Computer.new(registers, program, decode_map)
    local self = setmetatable({}, Computer)
    self.registers = {}
    self.program = program
    if (self.registers == nil) then
        self.registers = {0,0,0,0}
    else
        local r = 1
        while r <= #registers do
            self.registers[r] = registers[r]
            r = r + 1
        end
    end
    self.PC = 1
    self.decode_map = decode_map

    -- Instruction set
    self.IS = {
        addr = function(instr)
            self.registers[instr.c + 1] = self.registers[instr.a + 1] + self.registers[instr.b + 1]
        end,
        addi = function(instr)
            self.registers[instr.c + 1] = self.registers[instr.a + 1] + instr.b
        end,
        mulr = function(instr)
            self.registers[instr.c + 1] = self.registers[instr.a + 1] * self.registers[instr.b + 1]
        end,
        muli = function(instr)
            self.registers[instr.c + 1] = self.registers[instr.a + 1] * instr.b
        end,
        banr = function(instr)
            self.registers[instr.c + 1] = self.registers[instr.a + 1] & self.registers[instr.b + 1]
        end,
        bani = function(instr)
            self.registers[instr.c + 1] = self.registers[instr.a + 1] & instr.b
        end,
        borr = function(instr)
            self.registers[instr.c + 1] = self.registers[instr.a + 1] | self.registers[instr.b + 1]
        end,
        bori = function(instr)
            self.registers[instr.c + 1] = self.registers[instr.a + 1] | instr.b
        end,
        setr = function(instr)
            self.registers[instr.c + 1] = self.registers[instr.a + 1]
        end,
        seti = function(instr)
            self.registers[instr.c + 1] = instr.a
        end,
        gtir = function(instr)
            if instr.a > self.registers[instr.b + 1] then
                self.registers[instr.c + 1] = 1
            else
                self.registers[instr.c + 1] = 0
            end
        end,
        gtri = function(instr)
            if self.registers[instr.a + 1] > instr.b then
                self.registers[instr.c + 1] = 1
            else
                self.registers[instr.c + 1] = 0
            end
        end,
        gtrr = function(instr)
            if self.registers[instr.a + 1] > self.registers[instr.b + 1] then
                self.registers[instr.c + 1] = 1
            else
                self.registers[instr.c + 1] = 0
            end
        end,
        eqir = function(instr)
            if instr.a ==self.registers[instr.b + 1] then
                self.registers[instr.c + 1] = 1
            else
                self.registers[instr.c + 1] = 0
            end
        end,
        eqri = function(instr)
            if self.registers[instr.a + 1] == instr.b then
                self.registers[instr.c + 1] = 1
            else
                self.registers[instr.c + 1] = 0
            end
        end,
        eqrr = function(instr)
            if self.registers[instr.a + 1] == self.registers[instr.b + 1] then
                self.registers[instr.c + 1] = 1
            else
                self.registers[instr.c + 1] = 0
            end
        end
    }

    return self
end


function Computer.execute_instruction(self, name, instr)
    local inst_exec = self.IS[name]
    if inst_exec == nil then
        error("no instruction with name: "..name)
    end
    inst_exec(instr)
end

function Computer.execute(self)
    while self.PC <= #self.program do
        local instr = self.program[self.PC]
        local name, instr = self:decode(instr)
        self:execute_instruction(name, instr)
        self.PC = self.PC + 1
    end
end

function Computer.decode(self, instr)
    name = self.decode_map[instr.op + 1]
    if name == nil then
        error("woops, unknown opcode"..(instr.op + 1))
    end
    return name, instr
end

function Computer.print_registers(self)
    print("["..self.registers[1]..", "..self.registers[2]..", "..self.registers[3]..", "..self.registers[4].."]")
end

INSTRUCTIONS = {"addr", "addi", "mulr", "muli", "banr", "bani", "borr", 
                "bori", "setr", "seti", "gtir", "gtri", "gtrr", "eqir", 
                "eqri", "eqrr"}

-- // load input
function load_input(filename)
    local tests = {}
    local program = {}
    local in_test = false
    local testcount = 0

    for line in io.lines(filename) do
        if (line ~= "") then 
            if line:sub(1, #"Before: [") == "Before: [" then
                --print ("Start test ->"..line)
                in_test = true
                testcount = testcount + 1
                local r1,r2,r3,r4 = string.match(line, "(%d+),%s(%d+),%s(%d+),%s(%d+)")
                if r1 == nil or r2 == nil or r3 == nil or r4 == nil then
                    error("misparsed line: " .. line)
                end
                tests[testcount] = {
                    before = {tonumber(r1),tonumber(r2),tonumber(r3),tonumber(r4)}
                }
            else 
                if line:sub(1, #"After:") == "After:" then
                    --print("End test ->"..line)
                    in_test = false
                    local r1,r2,r3,r4 = string.match(line, "(%d+),%s(%d+),%s(%d+),%s(%d+)")
                    if r1 == nil or r2 == nil or r3 == nil or r4 == nil then
                        error("misparsed line: " .. line)
                    end
                    tests[testcount]["after"] = {tonumber(r1),tonumber(r2),tonumber(r3),tonumber(r4)}
                else
                    local op, a, b, c = string.match(line, "(%d+)%s(%d+)%s(%d+)%s(%d+)")
                    local instruction = {
                        op = tonumber(op),
                        a = tonumber(a),
                        b = tonumber(b),
                        c = tonumber(c)
                    }
                    if op == nil or a == nil or b == nil or c == nil then
                        error("Missparsed line for instruction: "..line)
                    end
                    if in_test then
                        --print("instruction(test): "..line)
                        tests[testcount]["instruction"] = instruction
                    else
                        --print("instruction(program):"..line.." "..#program)
                        program[#program+1] = instruction
                    end
                end
            end
        end
    end

    return tests, program
end

function test_instr(before, after, instr, name)
    local comp = Computer.new(before)
    comp:execute_instruction(name, instr)
    return comp.registers[1] == after[1] and
            comp.registers[2] == after[2] and
            comp.registers[3] == after[3] and
            comp.registers[4] == after[4]
end

function get_matching_instructions(test)
    local matching = {}
    local i = 1
    while i <= #INSTRUCTIONS do
        local name = INSTRUCTIONS[i]
        if test_instr(test.before, test.after, test.instruction, name) then
            matching[#matching + 1] = name
        end
        i = i+1
    end
    return matching
end

function generate_opcode_map(tests)
    local opcode_map = {}
    local decode_map = {}

    for i = 1,#tests do
        local test = tests[i]
        local opscore = opcode_map[test.instruction.op + 1]
        if opscore == nil then
            -- generate new OP score
            opscore = {}
            for j = 1,#INSTRUCTIONS do
                opscore[INSTRUCTIONS[j]] = 0
            end
            opcode_map[test.instruction.op + 1] = opscore
        end
        local possible = get_matching_instructions(test)
        for j = 1,#possible do
            opscore[possible[j]] = opscore[possible[j]] + 1
        end
    end

    local poss_map = {}
    for k,v in pairs(opcode_map) do
        local possibilities = get_max_score(v)
        poss_map[k] = possibilities
    end
    while count_decoded(decode_map) < 16 do
        local rk = {}
        for k,v in pairs(poss_map) do
            if #v == 1 then
                decode_map[k] = v[1]
                rk[#rk + 1] = v[1]
            end
        end
        for i = 1,#rk do
            for j = 1,#poss_map do
                removeel(poss_map[j], rk[i])
            end
        end
    end
    return decode_map
end

function removeel(tbl, val)
    local rk = {}
    for i = 1,#tbl do
        if tbl[i] == val then
            rk[#rk + 1] = i
        end
    end
    for i = 1,#rk do
        table.remove(tbl, rk[i])
    end
end

function count_decoded(tbl)
    local c = 0
    for i = 0,#tbl do
        if tbl[i] ~= nil then
            c = c + 1
        end
    end
    return c
end

function print_table(t)
    for k,v in pairs(t) do
        print(k..": "..v)
    end
end

function get_max_score(opscore) 
    local max_score=0
    local op_name=""
    local possible = {}

    for k,v in pairs(opscore) do
        if v > max_score then
            max_score = v
            op_name = k
        end
    end

    for k,v in pairs(opscore) do
        if v == max_score then
            possible[#possible + 1] = k
        end
    end

    return possible
end

function part1(tests)
    local count = 0
    local i = 1
    while i <= #tests do
        local test = tests[i]
        local matching = get_matching_instructions(test)
        if #matching >= 3 then
            count = count + 1
        end
        i = i + 1
    end
    return count
end


function part2(tests, program)
    local decode_map = generate_opcode_map(tests)
    local com = Computer.new({0,0,0,0}, program, decode_map)
    com:execute()
    return com.registers[1]
end

tests, program = load_input("input")

print("Part 1: "..part1(tests))
print("Part 2: " .. part2(tests, program))