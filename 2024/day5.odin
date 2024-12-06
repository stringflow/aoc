package aoc

import "core:fmt"
import "core:strings"
import "core:strconv"
import "core:slice"

PageRule :: struct {
    before: int,
    after: int,
}

validate :: proc(rules: []PageRule, update: []int) -> (valid: bool, idx1: int, idx2: int) {
    for cur_rule in rules {
        idx1, found1 := slice.linear_search(update, cur_rule.before)
        idx2, found2 := slice.linear_search(update, cur_rule.after)

        if found1 && found2 && idx1 > idx2 {
            return false, idx1, idx2
        }
    }

    return true, -1, -1
}

sort :: proc(rules: []PageRule, update: []int) {
    valid, idx1, idx2 := validate(rules, update)
    if !valid {
        slice.swap(update, idx1, idx2)
        sort(rules, update)
    }
}

sum_valid_updates :: proc(input: string, fix_incorrect: bool) -> (sum: int) {
    remainder := input
    
    rules := make([dynamic]PageRule, 0, context.temp_allocator)
    for line in strings.split_lines_iterator(&remainder) {
        if len(line) == 0 do break

        separator := strings.index_rune(line, '|')
        rule := PageRule {
            before = strconv.atoi(line[0:separator]),
            after = strconv.atoi(line[separator+1:]),
        }
        append(&rules, rule)
    }

    updates := make([dynamic][]int, 0, context.temp_allocator)
    for line in strings.split_lines_iterator(&remainder) {
        append(&updates, slice.mapper(strings.split(line, ","), strconv.atoi, context.temp_allocator))
    }

    for cur_update in updates {
        valid, _, _ := validate(rules[:], cur_update)

        if fix_incorrect {
            if !valid do sort(rules[:], cur_update)
            valid = !valid
        }
        
        if valid {
            sum += cur_update[len(cur_update) / 2]
        }
    }

    return sum
}

main :: proc() {
    example := #load("day5_example.txt", string)
    fmt.printfln("example: %d", sum_valid_updates(example, true))

    input := #load("day5_input.txt", string)
    fmt.printfln("part1: %d", sum_valid_updates(input, false))
    fmt.printfln("part2: %d", sum_valid_updates(input, true))
}