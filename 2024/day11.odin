package aoc

import "core:fmt"
import "core:strings"
import "core:strconv"
import "core:math"

cache := make(map[[2]int]int)

blink :: proc(stone: int, steps_remaining: int) -> (total_stones: int) {
    if steps_remaining == 0 do return 1

    key := [2]int{stone, steps_remaining}
    if key in cache do return cache[key]

    digits := int(math.log10_f32(f32(stone))) + 1
    if stone == 0 {
        total_stones = blink(1, steps_remaining - 1)
    } else if digits % 2 == 0 {
        power := int(math.pow_f32(10, f32(digits / 2)))
        total_stones += blink(stone / power, steps_remaining - 1) 
        total_stones += blink(stone % power, steps_remaining - 1)
    } else {
        total_stones = blink(stone*2024, steps_remaining - 1)
    }

    cache[key] = total_stones
    return total_stones
}

count_stones :: proc(input: string, total_blinks: int) -> (total: int) {
    input := input
    for stone in strings.fields_iterator(&input) {
        total += blink(strconv.atoi(stone), total_blinks)
    }

    return total
}

main :: proc() {
    example := #load("day11_example.txt", string)
    fmt.printfln("example: %v", count_stones(example, 25))

    input := #load("day11_input.txt", string)
    fmt.printfln("part1: %d", count_stones(input, 25))
    fmt.printfln("part2: %d", count_stones(input, 75))
}