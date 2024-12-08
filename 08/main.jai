/* =========================================================================
 * This is my solution for Advent of Code 2024 day 8
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
    run("08/test.txt", part_1);
    run("08/input.txt", part_1);

    print("=== Part 2 ===\n");
    run("08/test.txt", part_2);
    run("08/input.txt", part_2);
}

part_1 :: (path: string) {
    contents, success := read_entire_file(path);
    assert(success);

    map := parse(contents);
    result := count_unique_antinodes(map);

    print("Result : %\n", result);
}

part_2 :: (path: string) {
    contents, success := read_entire_file(path);
    assert(success);

    map := parse(contents);
    result := count_unique_antinodes(map, is_part_2 = true);

    print("Result : %\n", result);
}

Map :: struct {
    width, height: s16;
    antennas: [..]Antenna;
}

Antenna :: struct {
    frequency: Frequency;
    location: Location;
}

Location :: struct {
    x, y: s16;
}

Frequency :: u8;

is_antenna :: inline (char: u8) -> bool {
    return (char >= #char "a" && char <= #char "z")
        || (char >= #char "A" && char <= #char "Z")
        || (char >= #char "0" && char <= #char "9");
}

parse :: (content: string) -> Map {
    lines := split_newlines(content);
    lines.count -= 1;

    map: Map = .{
        width = xx lines[0].count,
        height = xx lines.count,
    };

    for line, y: lines {
        for char, x: line {
            if is_antenna(char) then array_add(*map.antennas, .{
                location = .{
                    x = xx x,
                    y = xx y,
                },
                frequency = char,
            });
        }
    }

    return map;
}

calculate_location :: inline(a: Location, b: Location) -> Location {
    return .{
        x = a.x + (a.x - b.x),
        y = a.y + (a.y - b.y),
    };
}

count_unique_antinodes :: (using map: Map, is_part_2: bool = false) -> u64 {
    count: u64;

    grid := NewArray(width * height, bool);
    defer array_free(grid);

    for antenna_a, a_index: antennas {
        for antenna_b, b_index: antennas {
            if a_index == b_index continue;
            if antenna_a.frequency != antenna_b.frequency continue;

            if grid[width * antenna_a.location.y + antenna_a.location.x] == false {
                grid[width * antenna_a.location.y + antenna_a.location.x] = true;
                count += 1;
            }
            if grid[width * antenna_b.location.y + antenna_b.location.x] == false {
                grid[width * antenna_b.location.y + antenna_b.location.x] = true;
                count += 1;
            }

            delta := Location.{
                x = antenna_a.location.x - antenna_b.location.x,
                y = antenna_a.location.y - antenna_b.location.y,
            };
            antinode_location := antenna_a.location;

            while true {
                defer if ! is_part_2 break;

                antinode_location.x += delta.x;
                antinode_location.y += delta.y;

                // Check if within map.
                if antinode_location.x < 0 || antinode_location.x >= width
                || antinode_location.y < 0 || antinode_location.y >= height {
                    break;
                }

                // Check if location already exists.
                if grid[width * antinode_location.y + antinode_location.x] {
                    continue;
                }

                grid[width * antinode_location.y + antinode_location.x] = true;
                count += 1;
            }
        }
    }

    return count;
}

#import "File";
#import "String";
#import "Basic";
#import "AoC_Utils";
