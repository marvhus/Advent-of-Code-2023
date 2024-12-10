/* =========================================================================
 * This is my day 10 solution for Advent of Code 2024.
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
    run("10/test.txt", part_1);
    run("10/input.txt", part_1);

    //print("=== Part 2 ===\n");
    //run("10/test.txt", part_2);
    //run("10/input.txt", part_2);
}

part_1 :: (path: string) {
    contents, success := read_entire_file(path);
    assert(success);

    map := parse(contents);
    visited := NewArray(map.width * map.height, bool);
    defer array_free(visited);

    result: int;
    for trailhead: map.trailheads {
        for *v: visited { v.* = false; }

        score := score_trail(map, trailhead.x, trailhead.y, visited);
        result += score;
    }

    print("Result : %\n", result);
}

part_2 :: (path: string) {
    contents, success := read_entire_file(path);
    assert(success);

    // @TODO(martin): Implement Part 2.
}

Location :: struct {
    x, y: int;
}

Map :: struct {
    width: int;
    height: int;
    cells: []u8;
    trailheads: [..]Location;
}

get_cell :: (map: Map, x: int, y: int) -> u8 {
    if x < 0
    || x >= map.width
    || y < 0
    || y >= map.height {
        return 0xFF;
    }

    return map.cells[map.width * y + x];
}

score_trail :: (map: Map, x: int, y: int, visited: []bool) -> int {
    {
        index := map.width * y + x;
        assert(index < visited.count);

        if visited[index] return 0;
        visited[index] = true;
    }

    current := map.cells[map.width * y + x];
    if current == 9 return 1;
    if current < 0 || current > 9 return 0;

    score: int;

    next := current + 1;
    if get_cell(map, x    , y + 1) == next then score += score_trail(map, x    , y + 1, visited);
    if get_cell(map, x    , y - 1) == next then score += score_trail(map, x    , y - 1, visited);
    if get_cell(map, x + 1, y    ) == next then score += score_trail(map, x + 1, y    , visited);
    if get_cell(map, x - 1, y    ) == next then score += score_trail(map, x - 1, y    , visited);

    return score;
}

parse :: (text: string) -> Map {
    lines := split_newlines(text);
    lines.count -= 1;

    map := Map.{
        width = lines[0].count,
        height = lines.count,
        cells = NewArray(lines[0].count * lines.count, u8),
    };

    for line, y: lines {
        for char, x: line {
            digit := char - #char "0";
            map.cells[map.width * y + x] = digit;

            if digit == 0 then array_add(*map.trailheads, Location.{y = y, x = x});
        }
    }

    return map;
}

#import "File";
#import "String";
#import "Basic";
#import "AoC_Utils";
#import "Hash_Table";
