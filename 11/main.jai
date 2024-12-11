/* =========================================================================
 * This is my day 11 solution for Advent of Code 2024.
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
    run("11/test.txt", part_1);
    //run("11/input.txt", part_1);

    //print("=== Part 2 ===\n");
    //run("11/test.txt", part_2);
    //run("11/input.txt", part_2);
}

part_1 :: (path: string) {
    contents, success := read_entire_file(path);
    assert(success);

    result := simulate(contents, 25,, temp);
    print("Result : %\n", result);

    reset_temporary_storage();
}

part_2 :: (path: string) {
    contents, success := read_entire_file(path);
    assert(success);

    result := simulate(contents, 75,, temp);
    print("Result : %\n", result);

    reset_temporary_storage();
}

simulate :: (input: string, count: int) -> result: u64 {
    // K: value, V: count.
    stones := New(Table(u64, u64));
    for stone: split(input, " ") {
        value := string_to_int(stone, 10, u64);
        count := find_or_add(stones, value);
        count.* += 1;
    }

    for 1..count {
        new_stones := New(Table(u64, u64));

        for count, value: stones {
            if value == 0 {
                other_count := find_or_add(new_stones, 1);
                other_count.* += count;

                continue;
            }

            number_string := tprint("%", value);
            if number_string.count % 2 == 0 {
                left_half := string.{
                    data = number_string.data,
                    count = number_string.count / 2
                };
                right_half := string.{
                    data = number_string.data + left_half.count,
                    count = number_string.count - left_half.count
                };

                left_value := string_to_int(left_half, 10, u64);
                right_value := string_to_int(right_half, 10, u64);

                left_count := find_or_add(new_stones, left_value);
                right_count := find_or_add(new_stones, right_value);

                left_count.* += count;
                right_count.* += count;

                continue;
            }

            new_count := find_or_add(new_stones, value * 2024);
            new_count.* += count;
        }

        for count, value: new_stones { print("% (%), ", value, count); }
        print("\n");

        { // Swap em, mash em, stick em in a stew...  (I wrote "Swap em" and I had to write the rest xD)
            free(stones);
            stones = new_stones;
        }
    }

    result: u64;
    for count: stones { result += count; }
    return result;
}

#import "File";
#import "String";
#import "Basic";
#import "AoC_Utils";
#import "Hash_Table";
