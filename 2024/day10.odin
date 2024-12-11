package aoc

import "core:fmt"
import "core:strings"
import "core:slice"

parse_tilemap :: proc(input: string) -> (tilemap: []int, width: int) {
    lines := strings.split_lines(input, context.temp_allocator)

    width = len(lines[0])
    height := len(lines)

    tilemap = make([]int, width*height)
    for line, y in lines {
        for rune, x in line {
            tilemap[x+y*width] = int(rune - '0')
        }
    }

    return tilemap, width
}

explore :: proc(tilemap: []int, width: int, start: int, distinct_trails: bool) -> (score: int) {
    queue := make([dynamic]int, context.temp_allocator)
    visited := make([]bool, len(tilemap), context.temp_allocator)

    append(&queue, start)
    visited[start] = true

    neighbors := []int{-1, 1, -width, width}

    for len(queue) > 0 {
        coord := pop(&queue)
        height := tilemap[coord]
        x := coord % width

        for offset in neighbors {
            new_coord := coord + offset
            if new_coord < 0 || 
               new_coord >= len(tilemap) ||
               (offset == -1 && x == 0) ||
               (offset == 1 && x == width - 1) {
                continue
            }

            new_height := tilemap[new_coord]
            if new_height != height + 1 || (!distinct_trails && visited[new_coord]) do continue
            
            visited[new_coord] = true
            
            if new_height == 9 do score += 1
            else do append(&queue, new_coord)
        }
    }

    return score
}

find_trailheads :: proc(input: string, distinct_trails: bool) -> (total: int) {
    tilemap, width := parse_tilemap(input)
    defer delete(tilemap)

    for tile, pos in tilemap {
        if tile == 0 do total += explore(tilemap, width, pos, distinct_trails)
    }

    return total
}

main :: proc() {
    example := #load("day10_example.txt", string)
    fmt.printfln("example: %v", find_trailheads(example, false))

    input := #load("day10_input.txt", string)
    fmt.printfln("part1: %d", find_trailheads(input, false))
    fmt.printfln("part2: %d", find_trailheads(input, true))
}