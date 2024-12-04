package aoc

import "core:fmt"
import "core:strings"
import "core:slice"
import "core:unicode/utf8"

Direction :: enum {
    NORTH,
    EAST,
    SOUTH,
    WEST,
    NORTH_EAST,
    NORTH_WEST,
    SOUTH_EAST,
    SOUTH_WEST,
}

DIRECTION_VECTORS := [Direction][2]int {
    .NORTH = {0, -1},
    .EAST = {1, 0},
    .SOUTH = {0, 1},
    .WEST = {-1, 0},
    .NORTH_EAST = {1, -1},
    .NORTH_WEST = {-1, -1},
    .SOUTH_EAST = {1, 1},
    .SOUTH_WEST = {-1, 1},
}

create_grid :: proc(input: string) -> (grid: [][]rune) {
    lines := strings.split_lines(input, context.temp_allocator)
    grid = make([][]rune, len(lines))
    for line, y in lines {
        grid[y] = utf8.string_to_runes(line)
    }

    return grid
}

delete_grid :: proc(grid: [][]rune) {
    for line in grid {
        delete(line)
    }

    delete(grid)
}

read_linear_word :: proc(position: [2]int, direction: Direction, grid: [][]rune) -> (result: string) {
    buffer: [4]rune
    current := position
    step := DIRECTION_VECTORS[direction]
    bounds: [2]int = {len(grid[0]), len(grid)}

    for i in 0..<len(buffer) {
        if current.x < 0 || current.x >= bounds.x || current.y < 0 || current.y >= bounds.y do break

        buffer[i] = grid[current.y][current.x]
        current += step
    }

    return utf8.runes_to_string(buffer[:])
}

count_xmas_in_all_directions :: proc(input: string) -> (result: int) {
    grid := create_grid(input)
    defer delete_grid(grid)

    for line, y in grid {
        for rune, x in line {
            if rune == 'X' {
                for direction in Direction {
                    word := read_linear_word({x, y}, direction, grid[:])
                    defer delete(word)
                    
                    if word == "XMAS" {
                        result += 1
                    }
                }
            }
        }
    }

    return result
}

read_x_word :: proc(position: [2]int, grid: [][]rune) -> (result: string) {
    buffer: [4]rune
    bounds: [2]int = {len(grid[0]), len(grid)}

    diagonals := []Direction { .NORTH_EAST, .NORTH_WEST, .SOUTH_EAST, .SOUTH_WEST }

    for direction, i in diagonals {
        next_position := position + DIRECTION_VECTORS[direction];
        if next_position.x < 0 || next_position.x >= bounds.x || next_position.y < 0 || next_position.y >= bounds.y do continue

        buffer[i] = grid[next_position.y][next_position.x]
    }

    return utf8.runes_to_string(buffer[:])
}

count_x_mas :: proc(input: string) -> (result: int) {
    grid := create_grid(input)
    defer delete_grid(grid)

    valid_combinations := []string { "SMSM", "SSMM", "MSMS", "MMSS"}

    for line, y in grid {
        for rune, x in line {
            if rune == 'A' {
                word := read_x_word({x, y}, grid[:])
                defer delete(word)
                    
                 if slice.contains(valid_combinations, word) {
                   result += 1
                }
            }
        }
    }

    return result
}

main :: proc() {
    example := #load("day4_example.txt", string)
    fmt.printfln("example: %d", count_xmas_in_all_directions(example))

    input := #load("day4_input.txt", string)
    fmt.printfln("part1: %d", count_xmas_in_all_directions(input))
    fmt.printfln("part2: %d", count_x_mas(input))
}