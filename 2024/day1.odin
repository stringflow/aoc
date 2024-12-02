package aoc

import "core:fmt"
import "core:math"
import "core:strings"
import "core:strconv"
import "core:sort"

parse_to_lists :: proc(locations: string) -> ([]int, []int) {
    lines := strings.split_lines(locations)
    defer delete(lines)

    num_lines := len(locations)
    left := make([]int, num_lines)
    right := make([]int, num_lines)
    
    for line, i in lines {
        tokens := strings.fields(line)
        defer delete(tokens)

        ok: bool
        left[i], ok = strconv.parse_int(tokens[0])
        right[i], ok = strconv.parse_int(tokens[1])
    }

    return left, right
}

total_distance :: proc(locations: string) -> int {
    left, right := parse_to_lists(locations)

    sort.quick_sort(left)
    sort.quick_sort(right)

    total: int
    for i in 0..<len(left) {
        distance := math.abs(left[i] - right[i])
        total += distance
    }

    return total
}

total_similarity :: proc(locations: string) -> int {
    left, right := parse_to_lists(locations)

    appearence_map := make(map[int]int)
    defer delete(appearence_map)

    for i in right {
        value, ok := &appearence_map[i]
        if ok {
            value^ += 1
        } else {
            appearence_map[i] = 1
        }
    }

    total: int
    for i in left {
        appearences := appearence_map[i] or_else 0
        similiarty := i * appearences
        total += similiarty
    }

    return total
}

main :: proc() {
    example := #load("day1_example.txt", string)
    fmt.printfln("example: %d", total_distance(example))

    input := #load("day1_input.txt", string)
    fmt.printfln("part1: %d", total_distance(input))
    fmt.printfln("part2: %d", total_similarity(input))
}