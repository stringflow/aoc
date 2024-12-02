package aoc

import "core:fmt"
import "core:math"
import "core:strings"
import "core:strconv"
import "core:sort"

num_unsafe_levels :: proc(report: string) -> int {
    levels_str := strings.split(report, " ")
    defer delete(levels_str)

    levels := make([]int, len(levels_str))
    defer delete(levels)
    for level, i in levels_str {
        ok: bool
        levels[i], ok = strconv.parse_int(level)
    }

    increasing := levels[0] < levels[1]
    previous := levels[0]
    unsafe_levels := 0

    for i in 1..<len(levels) {
        current := levels[i]
        difference := math.abs(current - previous)

        correct_order := (increasing && current > previous) || (!increasing && current < previous)
        difference_within_range := difference > 0 && difference <= 3

        if !correct_order || !difference_within_range {
            unsafe_levels += 1
        }

        previous = current
    }

    return unsafe_levels
}

num_safe_reports :: proc(reports: string, threshold: int) -> int {
    list := strings.split_lines(reports)
    defer delete(list)

    safe := 0
    for report in list {
        if num_unsafe_levels(report) <= threshold {
            safe += 1
        }
    }

    return safe
}

main :: proc() {
    example := #load("day2_example.txt", string)
    fmt.printfln("example: %d", num_safe_reports(example, 0))

    input := #load("day2_input.txt", string)
    fmt.printfln("part1: %d", num_safe_reports(input, 0))
    fmt.printfln("part2: %d", num_safe_reports(input, 1))
}