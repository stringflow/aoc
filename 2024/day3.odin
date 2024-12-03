package aoc

import "core:fmt"
import "core:math"

Scanner :: struct {
    str: string,
    pos: int,
    remaining: int,
}

scanner_init :: proc(str: string) -> Scanner {
    return Scanner {
        str = str,
        pos = 0,
        remaining = len(str),
    }
}

scanner_next :: proc(s: ^Scanner) -> (result: byte, ok: bool) {
    if s.remaining <= 0 do return

    result = s.str[s.pos]
    scanner_skip(s, 1)
    return result, true
}

scanner_skip :: proc(s: ^Scanner, amount: int) {
    amount := math.min(amount, s.remaining)
    s.pos += amount
    s.remaining -= amount
}

scanner_scan_beginning :: proc(s: ^Scanner, substr: string) -> (result: bool) {
    length := len(substr)
    result = s.remaining >= length && s.str[s.pos:s.pos+length] == substr
    if (result) do scanner_skip(s, length)
    return result
}

scanner_read_int_until_delimiter :: proc (s: ^Scanner, delimiter: byte) -> (result: int, ok: bool) {
    for {
        c := scanner_next(s) or_break
        is_numeric := c >= '0' && c <= '9'

        if c == delimiter do break
        else if !is_numeric do return

        result *= 10
        result += int(c - '0')
    }

    return result, true
}

scanner_read_mul :: proc (s: ^Scanner) -> (result: int, ok: bool) {
    a := scanner_read_int_until_delimiter(s, ',') or_return
    b := scanner_read_int_until_delimiter(s, ')') or_return

    return a * b, true
}

solve1 :: proc(instructions: string) -> (result: int) {
    scanner := scanner_init(instructions)

    for scanner.remaining > 0 {
        if scanner_scan_beginning(&scanner, "mul(") {
            result += scanner_read_mul(&scanner) or_continue
        } else {
            scanner_skip(&scanner, 1)
        }
    }

    return result
}

solve2 :: proc(instructions: string) -> (result: int) {
    scanner := scanner_init(instructions)
    enable := true

    for scanner.remaining > 0 {
        if enable && scanner_scan_beginning(&scanner, "mul(") {
            result += scanner_read_mul(&scanner) or_continue
        } else if scanner_scan_beginning(&scanner, "do()") {
            enable = true
        } else if scanner_scan_beginning(&scanner, "don't()") {
            enable = false
        } else {
            scanner_skip(&scanner, 1)
        }
    }

    return result
}

main :: proc() {
    example := #load("day3_example.txt", string)
    fmt.printfln("example: %d", solve1(example))

    input := #load("day3_input.txt", string)
    fmt.printfln("part1: %d", solve1(input))

    example2 := #load("day3_example2.txt", string)
    fmt.printfln("example2: %d", solve2(example2))
    fmt.printfln("part2: %d", solve2(input))
}