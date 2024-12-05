/* =========================================================================
 * This is template.jai
 * Copyright (C) 2024  marvhus
 * 
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * any later version
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 * ========================================================================== */

run :: (path : string, func : #type (string)->()) {
    print("Running with '%'\n", path);
    func(path);
}

main :: () {
    print("=== Part 1 ===\n");
    run("05/test.txt", part_1);
    run("05/input.txt", part_1);

    //print("=== Part 2 ===\n");
    //run("05/test.txt", part_2);
    //run("05/input.txt", part_2);
}

part_1 :: (path: string) {
    contents, success := read_entire_file(path);
    assert(success);

    rules_section, updates_section := parse_sections(contents);
    rules := parse_rules(rules_section);

    total: int;

    for update_line: split_newlines(updates_section) {
        if update_line.count == 0 continue;

        update_numbers := parse_update(update_line);

        if is_valid_update(update_numbers, rules) {
            total += update_numbers[update_numbers.count / 2];
        }

        array_free(update_numbers);
    }

    print("Result : %\n", total);
}

part_2 :: (path: string) {
    contents, success := read_entire_file(path);
    assert(success);

    // @TODO(martin): Implement Part 2.
}

is_valid_update :: (update_numbers: []u8, rules: Table(u8, [..]u8)) -> bool {
    for a_index: 0 .. update_numbers.count - 2 {
        a := update_numbers[a_index];

        for b_index: a_index + 1 .. update_numbers.count - 1 {
            b := update_numbers[b_index];

            before_array, found := table_find(*rules, a);
            if !found continue;

            for before_number: before_array {
                if before_number == b return false;
            }
        }
    }

    return true;
}

//
// TODO(mvh): Fix memory leaks.  Does it matter?
//

parse_sections :: (text: string) -> (rules_section: string, updates_section: string) {
    sections := split(text, "\n\n");
    assert(sections.count == 2);

    rules_section := sections[0];
    updates_section := sections[1];

    return rules_section, updates_section;
}

parse_rules :: (rules_section: string) -> Table(u8, [..]u8) {
    rules: Table(u8, [..]u8);

    for line: split_newlines(rules_section) {
        if line.count == 0 continue;

        page_numbers := split(line, "|");
        assert(page_numbers.count == 2);

        before := string_to_int(page_numbers[0], 10, u8);
        after := string_to_int(page_numbers[1], 10, u8);

        rule := find_or_add(*rules, after);
        array_add(rule, before);
    }

    return rules;
}

parse_update :: (update_line: string) -> []u8 {
    updates := split(update_line, ",");
    numbers := NewArray(updates.count, u8);
    for update, index: updates { 
        numbers[index] = string_to_int(update, 10, u8);
    }
    return numbers;
}

#import "File";
#import "String";
#import "Basic";
#import "AoC_Utils";
#import "Hash_Table";
