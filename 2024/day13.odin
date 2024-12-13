package aoc

import "core:fmt"
import "core:strings"
import "core:strconv"

// ax*s + bx*t = px
// ay*s + by*t = py

// ax*by*s + bx*by*t = px*by
// ay*bx*s + by*bx*t = py*bx

// ax*by*s - ay*bx*s = px*by - py*bx
// (ax*by - ay*bx) * s = px*by - py*bx
// s = (px*by - py*bx) / (ax*by - ay*bx)

// ax*s + bx*t = px
// bx*t = px - ax*s
// t = (px - ax*s) / bx
play_machine :: proc(a: [2]int, b: [2]int, p: [2]int) -> int {
    ca := (p.x*b.y - p.y*b.x) / (a.x*b.y - a.y*b.x)
    cb := (p.x - a.x*ca) / b.x

    if ca*a.x + cb*b.x == p.x && ca*a.y + cb*b.y == p.y {
        return ca * 3 + cb
    } else {
        return 0
    }
}

split :: proc(line: string, x: string, y: string) -> [2]int {
    substr, _ := strings.substring_from(line, len(x))
    parts := strings.split(substr, y, context.temp_allocator)
    return [2]int{
        strconv.atoi(parts[0]),
        strconv.atoi(parts[1]),
    }
}

total_tokens :: proc(input: string, price_offset: int) -> (tokens: int) {
    lines := strings.split_lines(input, context.temp_allocator)
    for i := 0; i < len(lines); i += 1 {
        a := split(lines[i], "Button A: X+", ", Y+")
        i += 1
        b := split(lines[i], "Button B: X+", ", Y+")
        i += 1
        p := split(lines[i], "Price: X=", ", Y=") + price_offset
        i += 1
        tokens += play_machine(a, b, p)
    }

    return tokens
}

main :: proc() {
    example := #load("day13_example.txt", string)
    fmt.printfln("example: %v", total_tokens(example, 0))

    input := #load("day13_input.txt", string)
    fmt.printfln("part1: %v", total_tokens(input, 0))
    fmt.printfln("part2: %v", total_tokens(input, 10000000000000))
}