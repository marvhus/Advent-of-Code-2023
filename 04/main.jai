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
    run("04/test.txt", part_1);
    run("04/input.txt", part_1);

    print("=== Part 2 ===\n");
    run("04/test2.txt", part_2);
    run("04/input.txt", part_2);
}

part_1 :: (path: string) {
    contents, success := read_entire_file(path);
    assert(success);

    lines := split_newlines(contents);
    lines.count -= 1;

    result: int;

    // Expects every line to be the same length.
    line_length := lines[0].count;

    for row, row_index: lines {
        for col, col_index: row {
            if col == #char "X" {
                result += count_around(lines, line_length, row_index, col_index);
            }
        }
    }

    print("Result : %\n", result);
}

part_2 :: (path: string) {
    contents, success := read_entire_file(path);
    assert(success);

    lines := split_newlines(contents);
    lines.count -= 1;

    result: int;

    // Expects every line to be the same length.
    line_length := lines[0].count;

    for row_index: 1..lines.count-2 {
        for col_index: 1..line_length-2 {
            if is_x_mas(lines, row_index, col_index) then result += 1;
        }
    }

    print("Result : %\n", result);
}

is_x_mas :: (lines: []string, row_index: int, col_index: int) -> bool {
    return (
        // Center.
        lines[row_index][col_index] == #char "A"
    ) && (
        // Diagonal. Top left - Bottom right
        (lines[row_index - 1][col_index - 1] == #char "M" && lines[row_index + 1][col_index + 1] == #char "S")
     || (lines[row_index - 1][col_index - 1] == #char "S" && lines[row_index + 1][col_index + 1] == #char "M")
    ) && (
        // Diagonal. Top right - Bottom right
        (lines[row_index - 1][col_index + 1] == #char "M" && lines[row_index + 1][col_index - 1] == #char "S")
     || (lines[row_index - 1][col_index + 1] == #char "S" && lines[row_index + 1][col_index - 1] == #char "M")
    );
}

count_around :: (lines: []string, line_length: int, row_index: int, col_index: int) -> int {
    total: int;
    OFFSET_FORWARD :: 3;
    OFFSET_BACKWARD :: 2;

    if col_index + OFFSET_FORWARD < line_length { // Forward.
        found := true;
        for char: "MAS" {
            current_char := lines[row_index][col_index + 1 + it_index];

            if current_char != char {
                found = false;
                break char;
            }
        }

        if found {
            //print("%,% Found forward\n", row_index, col_index);
            total += 1;
        }
    }

    if col_index > OFFSET_BACKWARD { // Backward.
        found := true;
        for char: "MAS" {
            current_char := lines[row_index][col_index - 1 - it_index];

            if current_char != char {
                found = false;
                break char;
            }
        }

        if found {
            //print("%,% Found backward\n", row_index, col_index);
            total += 1;
        }
    }

    if row_index + OFFSET_FORWARD < lines.count { // Downward.
        found := true;
        for char: "MAS" {
            current_char := lines[row_index + 1 + it_index][col_index];

            if current_char != char {
                found = false;
                break char;
            }
        }

        if found {
            //print("%,% Found downward\n", row_index, col_index);
            total += 1;
        }
    }

    if row_index > OFFSET_BACKWARD { // Upward.
        found := true;
        for char: "MAS" {
            current_char := lines[row_index - 1 - it_index][col_index];

            if current_char != char {
                found = false;
                break char;
            }
        }

        if found {
            //print("%,% Found upward\n", row_index, col_index);
            total += 1;
        }
    }

    if row_index + OFFSET_FORWARD < lines.count
    && col_index + OFFSET_FORWARD < line_length { // Diagonal. Towards bottom right.
        found := true;
        for char: "MAS" {
            current_char := lines[row_index + 1 + it_index][col_index + 1 + it_index];

            if current_char != char {
                found = false;
                break char;
            }
        }

        if found {
            //print("%,% Found diagonal toward bottom right\n", row_index, col_index);
            total += 1;
        }
    }

    if row_index > OFFSET_BACKWARD
    && col_index + OFFSET_FORWARD < line_length { // Diagonal. Towards top right.
        found := true;
        for char: "MAS" {
            current_char := lines[row_index - 1 - it_index][col_index + 1 + it_index];

            if current_char != char {
                found = false;
                break char;
            }
        }

        if found {
            //print("%,% Found diagonal toward top right\n", row_index, col_index);
            total += 1;
        }
    }

    if row_index + OFFSET_FORWARD < lines.count
    && col_index > OFFSET_BACKWARD { // Diagonal. Towards bottom left.
        found := true;
        for char: "MAS" {
            current_char := lines[row_index + 1 + it_index][col_index - 1 - it_index];

            if current_char != char {
                found = false;
                break char;
            }
        }

        if found {
            //print("%,% Found diagonal toward bottom left\n", row_index, col_index);
            total += 1;
        }
    }

    if row_index > OFFSET_BACKWARD
    && col_index > OFFSET_BACKWARD { // Diagonal. Towards top left.
        found := true;
        for char: "MAS" {
            current_char := lines[row_index - 1 - it_index][col_index - 1 - it_index];

            if current_char != char {
                found = false;
                break char;
            }
        }

        if found {
            //print("%,% Found diagonal toward top right\n", row_index, col_index);
            total += 1;
        }
    }

    return total;
}

#import "File";
#import "String";
#import "Basic";
#import "AoC_Utils";
