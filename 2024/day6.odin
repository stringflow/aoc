package main

import "core:fmt"
import "core:strings"

Direction :: enum {
    NORTH,
    EAST,
    SOUTH,
    WEST,
}

DIRECTION_VECTORS := [Direction][2]int {
    .NORTH = {0, -1},
    .EAST = {1, 0},
    .SOUTH = {0, 1},
    .WEST = {-1, 0},
}

TURNS := [Direction]Direction {
    .NORTH = .EAST,
    .EAST = .SOUTH,
    .SOUTH = .WEST,
    .WEST = .NORTH
}

Game :: struct {
    width: int,
    height: int,
    tiles: []Tile,
    guard_start: [2]int
}

Tile :: struct {
    collision: bool,
    visited: bool,
}

Guard :: struct {
    position: [2]int,
    direction: Direction,
}

create_game :: proc(input: string) -> (game: Game) {
    game.width = strings.index_rune(input, '\n')
    game.height = strings.count(input, "\n") + 1

    game.tiles = make([]Tile, game.width*game.height)

    lines := strings.split_lines(input)
    defer delete(lines)
    for line, y in lines {
        for rune, x in line {
            is_guard := rune == '^'
            is_collision := !is_guard && rune != '.'
            game.tiles[x + y * game.width] = Tile {
                collision = is_collision,
                visited = is_guard,
            }

            if is_guard {
                game.guard_start = {x,y}
            }
        }
    }

    return game
}

simulate :: proc(game: Game) -> (total_visited: int, loop_detected: bool) {
    total_visited = 1

    guard := Guard {
        position = game.guard_start,
        direction = .NORTH
    }
    seen_states := make(map[Guard]struct{})
    defer delete(seen_states)
    for {
        if guard in seen_states do return 0, true
        seen_states[guard] = {}

        next_pos := guard.position + DIRECTION_VECTORS[guard.direction]
        if next_pos.x < 0 || next_pos.x >= game.width || next_pos.y < 0 || next_pos.y >= game.height do break

        next_tile := &game.tiles[next_pos.x + next_pos.y * game.width]
        if next_tile.collision {
            guard.direction = TURNS[guard.direction]
        } else {
            if !next_tile.visited do total_visited += 1
            next_tile.visited = true
            guard.position = next_pos
        }
    }

    return total_visited, false
}

count_total_visited :: proc(input: string) -> (total_visited: int) {
    game := create_game(input)
    defer delete(game.tiles)

    total_visited, _ = simulate(game)
    return total_visited
}

count_possible_loops :: proc(input: string) -> (total_loops: int) {
    game := create_game(input)
    defer delete(game.tiles)

    for y in 0..<game.height {
        for x in 0..<game.width {
            tile := &game.tiles[x+y*game.width]
            if !tile.collision {
                tile.collision = true
                defer tile.collision = false

                _, loop_detected := simulate(game)
                if (loop_detected) do total_loops += 1
            }
        }
    }

    return total_loops
}

main :: proc() {
    example := #load("day6_example.txt", string)
    fmt.printfln("example: %d", count_total_visited(example))

    input := #load("day6_input.txt", string)
    fmt.printfln("part1: %d", count_total_visited(input))
    fmt.printfln("part2: %d", count_possible_loops(input))
}