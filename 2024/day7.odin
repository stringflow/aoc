package main

import "core:fmt"
import "core:strings"
import "core:strconv"
import "core:math"

Operation :: enum {
    ADD,
    MULTIPLY,
    CONCAT,
}

has_solution :: proc(current: int, target: int, values: []int, operations: []Operation) -> bool {
    values_left := len(values)

    if values_left == 0 do return current == target
    else if current > target do return false

    next := values[0]
    for operation in operations {
        new := current
        switch operation {
            case .ADD: 
                new += next
            case .MULTIPLY:
                new *= next
            case .CONCAT:
                digits := math.floor_f64(math.log10_f64(f64(next))) + 1
                shift := int(math.pow_f64(10, digits))
                new *= shift
                new += next
        }

        if has_solution(new, target, values[1:], operations) do return true
    }

    return false
}

sum_possible_equations :: proc(input: string, operations: []Operation) -> (sum: int) {
    lines := strings.split_lines(input)
    defer delete(lines)

    for line in lines {
        fields := strings.fields(line)
        defer delete(fields)

        target := strconv.atoi(fields[0])
        values := make([]int, len(fields)-1)
        defer delete(values)
        for i in 1..<len(fields) {
            values[i-1] = strconv.atoi(fields[i])
        }

        if has_solution(0, target, values, operations) do sum += target
    }

    return sum
}

main :: proc() {
    example := #load("day7_example.txt", string)
    fmt.printfln("example: %d", sum_possible_equations(example, []Operation{.ADD, .MULTIPLY}))

    input := #load("day7_input.txt", string)
    fmt.printfln("part1: %d", sum_possible_equations(input, []Operation{.ADD, .MULTIPLY}))
    fmt.printfln("part2: %d", sum_possible_equations(input, []Operation{.ADD, .MULTIPLY, .CONCAT}))
}