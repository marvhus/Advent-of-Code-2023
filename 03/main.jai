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
    run("03/test.txt", part_1);
    run("03/input.txt", part_1);

    print("=== Part 2 ===\n");
    run("03/test2.txt", part_2);
    run("03/input.txt", part_2);
}

part_1 :: (path: string) {
    contents, success := read_entire_file(path);
    assert(success);

    total := 0;

    offset := 0;
    while true {
        buffer := string.{data = contents.data + offset, count = contents.count - offset};

        valid, left, right, length := next_mul(buffer);
        offset += length;

        if valid == false {
            // No more mul operations.
            break;
        }

        total += left * right;
    }

    print("Result : %\n", total);
}

part_2 :: (path: string) {
    contents, success := read_entire_file(path);
    assert(success);

    total := 0;
    enabled := true;

    offset := 0;
    while true {
        buffer := string.{data = contents.data + offset, count = contents.count - offset};

        valid, left, right, length, new_enabled := next_mul(buffer, is_part_2 = true, enabled_by_default = enabled);
        enabled = new_enabled;
        offset += length;

        if valid == false {
            // No more mul operations in line.
            break;
        }

        total += left * right;
    }

    print("Result : %\n", total);
}

next_mul :: (buffer: string, is_part_2 := false, enabled_by_default := true) -> (valid: bool, left: int, right: int, length: int, enabled: bool) {
    enabled := enabled_by_default;

    offset := 0;
    while offset < buffer.count {
        if is_part_2 { // Do and dont.
            offset_buffer := string.{data = buffer.data + offset, count = buffer.count - offset};
            valid, new_enabled, length := extract_do_and_dont(offset_buffer);

            if valid {
                //if new_enabled print("!!ENABLED!!\n");
                //else print("!!DISABLED!!\n");
                enabled = new_enabled;
                offset += length;
                continue;
            }
        }

        { // Mul
            offset_buffer := string.{data = buffer.data + offset, count = buffer.count - offset};
            valid, left, right, length := extract_mul(offset_buffer); 

            if valid {
                //print(" enabled: %", enabled);
                if enabled {
                    //print(" -- % %\n", left, right);
                    offset += length;
                    return true, left, right, offset, true;
                }
                //print("\n");
            }
        }

        offset += 1;
    }

    // No more mul in line
    return false, 0, 0, 0, enabled;
}

extract_do_and_dont :: (buffer: string) -> (valid: bool, enabled: bool, length: int) {
    DONT_PREFIX :: "don't()";
    DO\ _PREFIX :: "do()";

    if begins_with(buffer, DONT_PREFIX) {
        return true, false, DONT_PREFIX.count;
    }
    if begins_with(buffer, DO_PREFIX) {
        return true, true, DO_PREFIX.count;
    }

    return false, false, 0;
}

extract_mul :: (buffer: string) -> (valid: bool, left: int, right: int, length: int) {
    offset := 0;

    MUL_PREFIX :: "mul(";
    if begins_with(buffer, MUL_PREFIX) == false {
        return false, 0, 0, 0;
    }
    offset += MUL_PREFIX.count;

    left, right: int;

    { // Left side.
        length := 0;
        while offset < buffer.count && is_digit(buffer[offset]) {
            left = (left * 10) + (buffer[offset] - #char "0");
            offset += 1;
            length += 1;
        }
        if length > 3 {
            return false, 0, 0, 0;
        }
    }

    if buffer[offset] != #char "," {
        return false, 0, 0, 0;
    }
    offset += 1;

    { // Right side.
        length := 0;
        while offset < buffer.count && is_digit(buffer[offset]) {
            right = (right * 10) + (buffer[offset] - #char "0");
            offset += 1;
            length += 1;
        }
        if length > 3 {
            return false, 0, 0, 0;
        }
    }

    if buffer[offset] != #char ")" {
        return false, 0, 0, 0;
    }
    offset += 1;

    //print("%", string.{data = buffer.data, count = offset});
    return true, left, right, offset;
}

#import "File";
#import "String";
#import "Basic";
#import "AoC_Utils";
