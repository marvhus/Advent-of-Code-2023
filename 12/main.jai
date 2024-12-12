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
      print("=== Part 1 ===\n");
      run("12/test.txt", part_1);
      run("12/input.txt", part_1);

      print("=== Part 2 ===\n");
      run("12/test.txt", part_2);
      run("12/input.txt", part_2);
}

part_1 :: (path: string) {
    contents, success := read_entire_file(path);
    assert(success);

    map := parse(contents,, temp);
    price := explore_map(map,, temp);

    print("Result : %\n", price);

    reset_temporary_storage();
}

part_2 :: (path: string) {
    contents, success := read_entire_file(path);
    assert(success);

    map := parse(contents,, temp);
    price := explore_map(map, is_part_2 = true,, temp);

    print("Result : %\n", price);

    reset_temporary_storage();
}

Location :: struct {
    x, y: int;
}

Map :: struct {
    width, height: int;
    cells: []u8;

    queued: [..]Location;
    visited: []bool;
}

parse :: (text: string) -> Map {
    lines := split_newlines(text);
    lines.count -= 1;

    map := Map.{
        height  = lines.count,
        width   = lines[0].count,
    };
    map.cells   = NewArray(map.width * map.height, u8);
    map.visited = NewArray(map.width * map.height, bool);

    for line, y: lines {
        for char, x: line {
            index := map.width * y + x;
            map.cells[index] = char;
            map.visited[index] = false;
        }
    }

    return map;
}

explore_map :: (map: Map, $is_part_2 := false) -> price: u64 {
    get_cell :: (using map: Map, y: int, x: int) -> u8 {
        if y < 0
        || y >= height
        || x < 0
        || x >= width {
            return 0;
        }

        return cells[width * y + x];
    }
    check_surounding :: (map: Map, region: u8, y: int, x: int, filled: [3 * 3]u8) -> u64 {
        count: u64;

        matrix := NewArray(3 * 3, u8);
        for filled { matrix[it_index] = it; }

        matrix2 := NewArray(3 * 3, u8);

        for 0..3 {
            // Check against matrix.
            success := true;
            for dy: 0..2 {
                for dx: 0..2 {
                    expected_to_be_filled := matrix[3 * dy + dx];
                    if expected_to_be_filled > 1 continue;
                    expected := expected_to_be_filled == 1;

                    cell := get_cell(map, y + dy - 1, x + dx - 1);
                    success &&= (cell == region) == expected;
                }
            }
            if success then count += 1;

            // Rotate matrix.
            matrix2[3 * 0 + 2] = matrix[3 * 0 + 0]; // left   top    -> right  top
            matrix2[3 * 1 + 2] = matrix[3 * 0 + 1]; // top    middle -> right  middle
            matrix2[3 * 2 + 2] = matrix[3 * 0 + 2]; // right  top    -> right  bottom
            matrix2[3 * 2 + 1] = matrix[3 * 1 + 2]; // right  middle -> bottom middle
            matrix2[3 * 2 + 0] = matrix[3 * 2 + 2]; // right  bottom -> left   bottom
            matrix2[3 * 1 + 0] = matrix[3 * 2 + 1]; // bottom middle -> left   middle
            matrix2[3 * 0 + 0] = matrix[3 * 2 + 0]; // left   bottom -> left   top
            matrix2[3 * 0 + 1] = matrix[3 * 1 + 0]; // left   middle -> top    middle
            matrix2[3 * 1 + 1] = matrix[3 * 1 + 1]; // middle        -> middle

            tmp := matrix;
            matrix = matrix2;
            matrix2 = tmp;
        }

        return count;
    }

    dfs :: (map: *Map, y: int, x: int, region: u8) -> (area: u64, perimeter: u64, corners: u64) {
        map.visited[xx map.width * y + x] = true;

        area: u64 = 1;
        perimeter: u64;
        corners: u64;

        for direction: Location.[
            .{x =  0, y = -1},
            .{x =  0, y =  1},
            .{x = -1, y =  0},
            .{x =  1, y =  0},
        ] {
            new_x := x + direction.x;
            new_y := y + direction.y;

            cell  := get_cell(map.*, new_y, new_x);
            if cell == 0 {
                perimeter += 1;
                continue;
            }

            visited := map.visited[map.width * new_y + new_x];

            if cell == region {
                if visited continue;

                new_area, new_perimeter, new_corners := dfs(map, new_y, new_x, region);
                area += new_area;
                perimeter += new_perimeter;
                corners += new_corners;
                continue;
            }

            perimeter += 1;

            if ! visited then array_add(*map.queued, Location.{new_x, new_y});
        }

        {
            F :: 0;
            T :: 1;
            U :: 2;

            corners += check_surounding(map, region, y, x, .[
                F, T, U,
                T, T, U,
                U, U, U,
            ]);
            corners += check_surounding(map, region, y, x, .[
                U, F, U,
                F, T, U,
                U, U, U,
            ]);
        }

        return area, perimeter, corners;
    }

    array_add(*map.queued, Location.{0, 0});
    price: u64;

    index := 0;
    while index < map.queued.count {
        defer index += 1;

        current := map.queued[index];

        array_index := map.width * current.y + current.x;
        if map.visited[array_index] == true continue;

        current_cell := map.cells[array_index];
        area, perimeter, corners := dfs(*map, current.y, current.x, current_cell);

        #if is_part_2 {
            total := area * corners;
            //print("% : % * % = %\n", cast(string)u8.[current_cell], area, corners, total);
        } else {
            total := area * perimeter;
        }
        price += total;
    }

    return price;
}

#import "File";
#import "String";
#import "Basic";
#import "AoC_Utils";
