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
    run("02/test.txt", part_1);
    run("02/input.txt", part_1);

    print("=== Part 2 ===\n");
    run("02/test.txt", part_2);
    run("02/input.txt", part_2);
}

part_1 :: (path: string) {
    contents, success := read_entire_file(path);
    assert(success);

    lines := split_newlines(contents);
    lines.count -= 1;

    total_safe := 0;

    for line: lines {
        number_strings := split(line, " ");
        numbers := NewArray(number_strings.count, u8);
        defer array_free(numbers);

        for number_string: number_strings {
            numbers[it_index] = string_to_int(number_string, 10, u8);
        }

        if is_report_safe(numbers) {
            total_safe += 1;
            continue;
        }
    }

    print("Result : %\n", total_safe);
}

part_2 :: (path: string) {
    contents, success := read_entire_file(path);
    assert(success);

    lines := split_newlines(contents);
    lines.count -= 1;

    total_safe := 0;

    for line: lines {
        number_strings := split(line, " ");
        numbers := NewArray(number_strings.count, u8);
        defer array_free(numbers);

        for number_string: number_strings {
            numbers[it_index] = string_to_int(number_string, 10, u8);
        }

        if is_report_safe(numbers) {
            total_safe += 1;
            continue line;
        }

        for 0..numbers.count-1 {
            new_levels := clone_report_with_level_removed(numbers, it);
            assert(new_levels.count == numbers.count - 1);
            defer array_free(new_levels);

            if is_report_safe(new_levels) {
                total_safe += 1;
                continue line;
            }
        }

    }

    print("Result : %\n", total_safe);
}

clone_report_with_level_removed :: (levels: []u8, remove_level_index: int) -> []u8 {
    new_levels := NewArray(levels.count - 1, u8);

    level_index := 0;
    for level: levels {
        if it_index == remove_level_index then continue;

        new_levels[level_index] = level;
        level_index += 1;
    }

    return new_levels;
}

Direction :: enum {
    NONE;
    INCREASING;
    DECREASING;
};

is_report_safe :: (levels: []u8) -> (is_safe: bool) {
    direction := Direction.NONE;

    for 0..levels.count-2 {
        level_a := levels[it];
        level_b := levels[it + 1];

        new_direction, is_safe := is_level_pair_safe(level_a, level_b, direction);

        if is_safe {
            direction = new_direction;
            continue;
        }

        return false;
    }

    return true;
}

is_level_pair_safe :: (level_a: u8, level_b: u8, current_direction: Direction) -> (new_direction: Direction, is_safe: bool) {
    new_direction := Direction.NONE;

    { // Check direction.
        if level_a > level_b then new_direction = .DECREASING;
        if level_a < level_b then new_direction = .INCREASING;

        if new_direction == .NONE {
            return new_direction, false;
        }

        if current_direction != new_direction && current_direction != .NONE {
            return new_direction, false;
        }
    }

    { // Check distance.
        distance := max(level_a, level_b) - min(level_a, level_b);

        if distance < 1 {
            return new_direction, false;
        }
        if distance > 3 {
            return new_direction, false;
        }
    }

    return new_direction, true;
}

#import "Math";
#import "File";
#import "String";
#import "Basic";
#import "AoC_Utils";
