package aoc

import "core:fmt"
import "core:strings"
import "core:slice"

parse_antennas :: proc(input: string) -> (antennas: map[byte][dynamic][2]int, bounds: [2]int) {
    lines := strings.split_lines(input)
    defer delete(lines)

    bounds = {len(lines[0]), len(lines)}

    for y in 0..<bounds.y {
        for x in 0..<bounds.x {
            freq := lines[y][x]
            if freq != '.' {
                antenna := antennas[freq] or_else {}
                append(&antenna, [2]int{x,y})
                antennas[freq] = antenna
            }
        }
    }

    return antennas, bounds
}

num_unique_antinodes :: proc(input: string, keep_stepping: bool) -> (count: int) {
    antenna_map, bounds := parse_antennas(input)
    antinodes := make([dynamic][2]int)
    defer delete(antinodes)

    for freq in antenna_map {
        antennas := antenna_map[freq] or_else {}
        for antenna1 in antennas {
            
            if keep_stepping && !slice.contains(antinodes[:], antenna1) do append(&antinodes, antenna1)

            for antenna2 in antennas {
                if antenna1 != antenna2 {
                    dir := antenna2 - antenna1
                    antinode := dir + antenna2

                    for antinode.x >= 0 && antinode.x < bounds.x && antinode.y >= 0 && antinode.y < bounds.y {
                        if !slice.contains(antinodes[:], antinode) do append(&antinodes, antinode)

                        if !keep_stepping do break
                        else do antinode += dir
                    }
                }
            }
        }
    }

    return len(antinodes)
}

main :: proc() {
    example := #load("day8_example.txt", string)
    fmt.printfln("example: %d", num_unique_antinodes(example, false))

    input := #load("day8_input.txt", string)
    fmt.printfln("part1: %d", num_unique_antinodes(input, false))
    fmt.printfln("part2: %d", num_unique_antinodes(input, true))
}