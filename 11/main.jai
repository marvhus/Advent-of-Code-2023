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
    run("11/input.txt", part_1);

    print("=== Part 2 ===\n");
    run("11/test.txt", part_2);
    run("11/input.txt", part_2);
}

part_1 :: (path: string) {
    contents, success := read_entire_file(path);
    assert(success);

    a := seconds_since_init();
    result := simulate(contents, 25,, temp);
    b := seconds_since_init();

    print("Result : %\n", result);
    print("Total % ms\n", (b - a) * 1000);
    print("---\n");

    reset_temporary_storage();
}

part_2 :: (path: string) {
    contents, success := read_entire_file(path);
    assert(success);

    a := seconds_since_init();
    result := simulate(contents, 75,, temp);
    b := seconds_since_init();

    print("Result : %\n", result);
    print("Total % ms\n", (b - a) * 1000);
    print("---\n");

    reset_temporary_storage();
}

simulate :: (input: string, count: int) -> result: u64 {
    count_digits :: (number: u64) -> u64 {
        count: u64 = 1;
        n := number;
        while n >= 10 {
            n /= 10;
            count += 1;
        }
        return count;
    }
    split :: (number: u64) -> u64, u64 {
        text := tprint("%", number);

        left  := string.{data = text.data, count = text.count / 2};
        right := string.{data = text.data + left.count, count = text.count - left.count};

        left_value  := string_to_int(left , 10, u64);
        right_value := string_to_int(right, 10, u64);

        return left_value, right_value;
    }

    // K: value, V: count.
    stones := New(Table(u64, u64));
    for stone: split(input, " ") {
        value := string_to_int(stone, 10, u64);
        count := find_or_add(stones, value);
        count.* += 1;
    }

    new_stones := New(Table(u64, u64));

    for 1..count {
        for count, value: stones {
            if value == 0 {
                a := find_or_add(new_stones, 1);
                a.* += count;

                continue;
            }

            digits := count_digits(value);
            if digits % 2 == 0 {
                left, right := split(value);

                a := find_or_add(new_stones, left);
                a.* += count;

                a = find_or_add(new_stones, right);
                a.* += count;

                continue;
            }

            a := find_or_add(new_stones, value * 2024);
            a.* += count;
        }

        { // Swap em, mash em, stick em in a stew...  (I wrote "Swap em" and I had to write the rest xD)
            table_reset(stones);
            tmp := stones;
            stones = new_stones;
            new_stones = tmp;
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
