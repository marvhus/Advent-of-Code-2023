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

run :: (path: string, $func: #type (string)->()) {
    print("Running with '%'\n", path);
    func(path);
}

main :: () {
    print("=== Part 1 ===\n");
    run("01/test.txt", part_1);
    run("01/input.txt", part_1);

    print("=== Part 2 ===\n");
    run("01/test.txt", part_2);
    run("01/input.txt", part_2);

}

compare :: (a: u32, b: u32) -> s64 {
    delta := (cast(int) a) - (cast(int) b);
    if delta < 0 then return -1;
    if delta > 0 then return  1;
    return 0;
}

part_1 :: (path: string) {
    contents, success := read_entire_file(path);
    assert(success);

    // - sort the left and right lists
    // - pair the smallest numbers on each side, and then continue with the next smallest, etc.
    // - add up the distances between the left and right numbers

    rows := split_newlines(contents);
    // it includes an empty line at the end.
    rows.count -= 1;

    left := NewArray(rows.count, u32);
    right := NewArray(rows.count, u32);

    // extract left and right values
    for row, row_index: rows {
        columns := split(row, "   ");
        assert(columns.count == 2);

        left[row_index]  = string_to_int(columns[0], 10, u32);
        right[row_index] = string_to_int(columns[1], 10, u32);
    }

    quick_sort(left, compare);
    quick_sort(right, compare);

    // sum the deltas
    deltas := 0;
    for 0..rows.count-1 {
        left_value := left[it];
        right_value := right[it];
        delta := max(left_value, right_value) - min(left_value, right_value);
        deltas += delta;
    }

    print("Result : %\n", deltas);

    array_free(left);
    array_free(right);
}

part_2 :: (path: string) {
    contents, success := read_entire_file(path);
    assert(success);

    // - add up the occurances in the right list of numbers
    // - multiply each number in the left list by the amount of times it occours in the right list
    // - add up these multiplied numbers

    rows := split_newlines(contents);
    // it includes an empty line at the end.
    rows.count -= 1;

    left := NewArray(rows.count, u32);
    occurances: Table(u32, u32);

    for row, row_index: rows {
        columns := split(row, "   ");
        assert(columns.count == 2);

        left_value := string_to_int(columns[0], 10, u32);
        right_value := string_to_int(columns[1], 10, u32);

        left[row_index] = left_value;

        entry, just_created := find_or_add(*occurances, right_value);
        if just_created {
            entry.* = 1;
            continue;
        }

        entry.* += 1;
    }

    sum := 0;

    for num: left {
        entry, success := table_find(*occurances, num);
        if success == false then continue;

        sum += num * entry;
    }

    print("Result : %\n", sum);

    array_free(left);
}

#import "File";
#import "Basic";
#import "Sort";
#import "String";
#import "AoC_Utils";
#import "Hash_Table";
