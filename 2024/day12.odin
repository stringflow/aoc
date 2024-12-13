package aoc

import "core:fmt"
import "core:strings"

Region :: struct {
    label: rune,
    area: int,
    perimeter: int,
    edges: int,
}

Tilemap :: struct {
    tiles: []rune,
    width: int,
    height: int,
}

Neighbor :: struct {
    v: bool,
    p: int
}

check_neighbor :: proc(tilemap: Tilemap, pos: int, x_offset: int, y_offset: int) -> (neighbor: Neighbor) {
    x := (pos % tilemap.width) + x_offset
    y := (pos / tilemap.width) + y_offset

    if x < 0 || x >= tilemap.width || y < 0 || y >= tilemap.height {
        return Neighbor{false, -1}
    }

    neighbor_pos := x+y*tilemap.width
    return Neighbor { tilemap.tiles[pos] == tilemap.tiles[neighbor_pos], neighbor_pos }
}

explore_region :: proc(tilemap: Tilemap, seen: ^[]bool, pos: int, region: ^Region) {
    if seen[pos] do return
    seen[pos] = true

    region.area += 1
    
    l := check_neighbor(tilemap, pos, -1, 0)
    r := check_neighbor(tilemap, pos, 1, 0)
    u := check_neighbor(tilemap, pos, 0, -1)
    d := check_neighbor(tilemap, pos, 0, 1)
    
    neighbors := []Neighbor{l, r, u, d}
    for neighbor in neighbors {
        if neighbor.v do explore_region(tilemap, seen, neighbor.p, region)
        else do region.perimeter += 1
    }

    lu := check_neighbor(tilemap, pos, -1, -1)
    ru := check_neighbor(tilemap, pos, 1, -1)
    ld := check_neighbor(tilemap, pos, -1, 1)
    rd := check_neighbor(tilemap, pos, 1, 1)
    
    corners := [][3]Neighbor{
        {l, u, lu},
        {r, u, ru},
        {l, d, ld},
        {r, d, rd},
    }
    for corner in corners {
        if (!corner[0].v && !corner[1].v) ||
           (corner[0].v && corner[1].v && !corner[2].v) {
            region.edges += 1
        }
    }
}

parse_garden :: proc(input: string) -> (regions: [dynamic]Region) {
    lines := strings.split_lines(input, context.temp_allocator)

    width := len(lines[0])
    height := len(lines)
    tilemap := Tilemap{make([]rune, width*height, context.temp_allocator), width, height}
    for line, y in lines {
        for rune, x in line {
            tilemap.tiles[x+y*width] = rune
        }
    }

    seen := make([]bool, width*height, context.temp_allocator)
    for tile, pos in tilemap.tiles {
        if seen[pos] do continue

        region := Region{tile, 0, 0, 0}
        explore_region(tilemap, &seen, pos, &region)
        append(&regions, region)
    }

    return regions
}

garden_price :: proc(input: string, discount: bool) -> (price: int) {
    regions := parse_garden(input)
    defer delete(regions)

    for region in regions do price += region.area * (discount ? region.edges : region.perimeter)

    return price
}

main :: proc() {
    example := #load("day12_example.txt", string)
    fmt.printfln("example: %v", garden_price(example, false))

    input := #load("day12_input.txt", string)
    fmt.printfln("part1: %v", garden_price(input, false))
    fmt.printfln("part2: %v", garden_price(input, true))
}