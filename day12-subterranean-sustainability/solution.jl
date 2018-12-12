function  loadInput(inpf::String)
    instructions = Dict()
    state = []
    open(inpf) do f
        for line in eachline(f)
            line = strip(line)
            if startswith(line, "initial state: ")
                state = [string(c) for c in split(line[16:end], "")]
            elseif line == ""
                println("skip")
            else
                instructions[string(line[1:5])] = string(line[end]) 
            end
        end
    end
    return (state, instructions)
end

function nextState(state, instructions, start)
    next_state = []
    state = [[".", ".", "."]; state; [".", ".", "."]]
   
    for i in 3:(length(state) - 2)
        key = join(state[i-2:i+2], "")
        if haskey(instructions, key)
            push!(next_state, instructions[key])
        else
            push!(next_state, ".")
        end
    end

   if next_state[1] == "#"
        start -= 1
    else
        next_state = next_state[2:end]
    end

    if next_state[end] != "#"
        next_state = next_state[1:end-1]
    end

    return (next_state, start)
end

function part1(iterations, state, instructions)
    start = 0
    for i in 1:iterations
        (state, start) = nextState(state, instructions, start)
    end
    count = 0
    for i in 1:length(state)
        if state[i] == "#"
            count = count + start
        end
        start += 1
    end
    return count
end

function getPlantPattern(state)
    start = 1
    pend = length(state)
   
    while true
        if state[start] == "#"
            break
        end
        start += 1
    end

    while true
        if state[pend] == "#"
            break
        end
        pend -= 1
    end
    return (start, pend, state[start:pend])
end

function part2(iterations, state, instructions)
    start = 0
    prevPattern = []
    patternDetectedAt = 0
    for i in 1:iterations
        (state, start) = nextState(state, instructions, start)
        if (i % 10) == 0
            j = 1
            while true
                if state[j] == "."
                    j+=1
                else
                    break
                end
            end
            state = state[j:end]
            start += j-1
            (s, _, pattern) = getPlantPattern(state)

            if join(pattern, "") == join(prevPattern, "")
                patternDetectedAt = i
                d = iterations-i
                start += d
                println("Pattern detected in the cellular automata calculation: ", join(pattern, ""))
                println("  detected at: ", i)
                println("  offset=", start)
                break
            end
            prevPattern = pattern
        end
    end

    count = 0
    for i in 1:length(prevPattern)
        if prevPattern[i] == "#"
            count = count + start
        end
        start += 1
    end
    return count
end

(state, instructions) = loadInput("input")
println("Initial state: ", join(state, ""))
count = part1(20, state, instructions)

println("Part 1: ", count)

res = part2(50000000000, state, instructions)
println("Part 2: ", res)