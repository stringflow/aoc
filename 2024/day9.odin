package aoc

import "core:fmt"
import "core:strings"
import "core:slice"

FREE :: -1

digit_to_int :: proc(r: rune) -> int {
    return int(r - '0')
}

parse_disk :: proc(input: string) -> (disk: []int) {
    size := 0
    for r in input {
        size += digit_to_int(r)
    }

    disk = make([]int, size)
    slice.fill(disk, FREE)

    id := 0
    ptr := 0
    for r, i in input {
        size = digit_to_int(r)
        defer ptr += size
        
        if i % 2 == 0 {
            slice.fill(disk[ptr:ptr+size], id)
            id += 1
        }
    }

    return disk
}

sort_files :: proc(disk: ^[]int) {
    left := 0
    right := len(disk) - 1
    for {
        for disk[right] == FREE do right -= 1
        for disk[left] != FREE do left += 1
        if left < right do slice.swap(disk^, left, right)
        else do break
    }
}

sort_blocks :: proc(disk: ^[]int) {
    blocks := make([dynamic][]int, 0)
    defer delete(blocks)
    i := 0
    for i < len(disk) {
        size := 1
        for i+size < len(disk) && disk[i+size] == disk[i] do size += 1
        append(&blocks, disk[i:i+size])
        i += size
    }

    #reverse for src_block, right in blocks {
        if src_block[0] == FREE do continue

        for dest_block, left in blocks {
            if left > right do break

            free := 0
            for free < len(dest_block) && dest_block[free] != FREE do free += 1

            if len(dest_block)-free >= len(src_block) {
                slice.swap_between(dest_block[free:], src_block)
            }
        }
    }
}

compute_checksum :: proc(disk: []int) -> (checksum: int) {
    for v, i in disk {
        if v == FREE do continue
        checksum += v * i
    }

    return checksum
}

solve :: proc(input: string, sort_by_block: bool) -> (checksum: int) {
    disk := parse_disk(input)
    defer delete(disk)

    if sort_by_block do sort_blocks(&disk)
    else do sort_files(&disk)

    return compute_checksum(disk)
}

main :: proc() {
    example := #load("day9_example.txt", string)
    fmt.printfln("example: %v", solve(example, false))

    input := #load("day9_input.txt", string)
    fmt.printfln("part1: %d", solve(input, false))
    fmt.printfln("part2: %d", solve(input, true))
}