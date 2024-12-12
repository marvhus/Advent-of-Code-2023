/* =========================================================================
 * This is my day 12 solution for Advent of Code 2024.
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
    //print("%\n", calculate_pricing("AAA\nABA\nAAA\n"));
    print("=== Part 1 ===\n");
    run("12/test.txt", part_1);
    run("12/input.txt", part_1);

    print("=== Part 2 ===\n");
    run("12/test.txt", part_2);
    run("12/input.txt", part_2);
}

get_cell :: (lines: []string, y: int, x: int) -> u8 {
    if y < 0
    || y >= lines.count
    || x < 0
    || x >= lines[0].count {
        return 0;
    }
    return lines[y][x];
}

part_1 :: (path: string) {
    contents, success := read_entire_file(path);
    assert(success);

    result := calculate_pricing(contents);
    print("Result : %\n", result);
}

calculate_pricing :: (text: string) -> u64 {
    lines := split_newlines(text);
    lines.count -= 1;

    height := lines.count;
    width  := lines[0].count;

    result: u64;

    for region: #char "A" .. #char "Z" {
        //print("Region %\n", cast(string)u8.[xx region]);
        area: u64;
        perimeter: u64;

        for line, y: lines {
            for char, x: line {
                if char != region continue;
                //print("  y: %, x: %\n", y + 1, x + 1);

                area += 1;

                p: u64;
                if get_cell(lines, y - 1, x) != region then p += 1;
                if get_cell(lines, y + 1, x) != region then p += 1;
                if get_cell(lines, y, x - 1) != region then p += 1;
                if get_cell(lines, y, x + 1) != region then p += 1;
                //print("  Perimeter %\n", p);
                perimeter += p;
            }
        }
        total := area * perimeter;
        if area > 0 then print("Region: % -- Area: %, Perimeter: % -- Total: %\n",
            cast(string)u8.[xx region], area, perimeter, total);
        result += total;
    }

    return result;
}

part_2 :: (path: string) {
    contents, success := read_entire_file(path);
    assert(success);

    // @TODO(martin): Implement Part 2.
}

#import "File";
#import "String";
#import "Basic";
#import "AoC_Utils";
