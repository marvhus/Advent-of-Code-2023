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
    run("03/test.txt", part_2);
    run("03/input.txt", part_2);
}

part_1 :: (path: string) {
    contents, success := read_entire_file(path);
    assert(success);

    lines := split_newlines(contents);
    lines.count -= 1;

    total := 0;

    for line: lines {
        total += sum_memory_line(line);
    }

    print("Result : %\n", total);
}

part_2 :: (path: string) {
    contents, success := read_entire_file(path);
    assert(success);

    // @TODO(martin): Implement Part 2.
}

sum_memory_line :: (line: string) -> int {
    //print("Working on: %\n", line);

    sum := 0;

    index := 0;
    while index < line.count {
        //print("------------\n");
        buffer := string.{data = line.data + index, count = line.count - index};
        valid, a, b, instruction_length := extract_mul_instruction(buffer);

        if valid == false {
            index += 1;
            continue;
        }

        //print("= mul(%,%)\n", a, b);

        result := a * b;
        sum += result;

        index += instruction_length;
    }

    return sum;
}

extract_mul_instruction :: (line: string) -> (valid: bool, a: int, b: int, instruction_length: int) {
    instruction_length := 0;
    buffer := string.{data = line.data, count = line.count};

    { // Check if begins with "mul"
        PREFIX :: "mul";
        if begins_with(buffer, PREFIX) == false {
            //print("Doesn't start with prefix... %\n", buffer);
            return false, 0, 0, 0;
        }

        buffer.count -= PREFIX.count;
        buffer.data += PREFIX.count;
        instruction_length += PREFIX.count;

        if buffer.count <= 0 {
            //print("End of buffer.\n");
            return false, 0, 0, 0;
        }
    }

    { // Check if balanced parenthesis.
        if buffer[0] != #char "(" {
            //print("Missing ( after prefix... %\n", buffer);
            return false, 0, 0, 0;
        }

        other_index := find_index_from_left(buffer, #char ")");
        if other_index == -1 {
            //print("Missing ) after (... %\n", buffer);
            return false, 0, 0, 0;
        }

        buffer.count = other_index - 1;
        buffer.data += 1;
        instruction_length += other_index;
    }

    { // Validate inside parenthesis.
        commas := 0;
        for c: buffer {
            if c == #char "," {
                commas += 1;
                if commas > 1 {
                    //print("Duplicate comma... %\n", buffer);
                    return false, 0, 0, 0;
                }
                continue;
            }

            if c >= #char "0" && c <= #char "9" {
                continue;
            }

            //print("Invalid character '%'... %\n", cast(string) u8.[c], buffer);
            return false, 0, 0, 0;
        }
    }

    a, b: int;
    { // Extract numbers
        number_strings := split(buffer, ",");
        assert(number_strings.count == 2);

        if number_strings[0].count > 3
        || number_strings[1].count > 3 {
            //print("Number string too long... %\n", number_strings);
            return false, 0, 0, 0;
        }

        a = string_to_int(number_strings[0], 10, int);
        b = string_to_int(number_strings[1], 10, int);
    }

    return true, a, b, instruction_length;
}

#import "File";
#import "String";
#import "Basic";
#import "AoC_Utils";
