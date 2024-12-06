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
    //print("=== Part 1 ===\n");
    //run("06/test.txt", part_1);
    //run("06/input.txt", part_1);

    print("=== Part 2 ===\n");
    run("06/test.txt", part_2);
    run("06/input.txt", part_2);
}

part_1 :: (path: string) {
    contents, success := read_entire_file(path);
    assert(success);

    map, guard := parse_map(contents);

    guard_tracker := NewArray(map.cells.count, bool);
    guard_tracker[map.width * guard.y + guard.x] = true;

    result := 1;

    while ! guard_step(*guard, map) {
        if guard_tracker[map.width * guard.y + guard.x] == false {
            result += 1;
            guard_tracker[map.width * guard.y + guard.x] = true;
        }
    }

    print ("Result : %\n", result);
}

part_2 :: (path: string) {
    contents, success := read_entire_file(path);
    assert(success);

    map, guard := parse_map(contents);

    rotation_points: [..]Vector2_s16;
    found_locations: Table(s32, void);

    result := 0;

    direction := guard.direction;
    position := guard.position;
    while ! guard_step(*guard, map) {
        result += check_block_location(guard, rotation_points, *found_locations);

        if direction != guard.direction {
            direction = guard.direction;
            array_add(*rotation_points, position);
        }

        position = guard.position;
    }

    print("Result : %\n", result);
}

Vector2_s16 :: struct {
    x, y: s16;
}

Map :: struct {
    width, height: s16;
    cells: []bool;
}

Direction :: enum {
    NORTH;
    EAST;
    SOUTH;
    WEST;
}

Guard :: struct {
    using position: Vector2_s16;
    direction: Direction;
}

check_block_location :: (guard: Guard, rotation_points: [..]Vector2_s16, found_locations: *Table(s32, void)) -> (found: int) {
    to_key :: (a: Vector2_s16) -> s32 {
        x: s32 = xx a.x;
        y: s32 = xx a.y;
        return (x << 15) | y;
    }

    count := 0;

    for rotation_point: rotation_points {
        if #complete guard.direction == {
            case .NORTH;
                new := Vector2_s16.{ guard.x, guard.y - 1 };
                key := to_key(new);

                if table_contains(found_locations, key) == false
                && guard.y == rotation_point.y
                && guard.x < rotation_point.x {

                    find_or_add(found_locations, key);
                    count += 1;
                }
            case .EAST;
                new := Vector2_s16.{ guard.x + 1, guard.y };
                key := to_key(new);

                if table_contains(found_locations, key) == false
                && guard.x == rotation_point.x
                && guard.y < rotation_point.y {

                    find_or_add(found_locations, key);
                    count += 1;
                }
            case .SOUTH;
                new := Vector2_s16.{ guard.x, guard.y + 1 };
                key := to_key(new);

                if table_contains(found_locations, key) == false
                && guard.y == rotation_point.y
                && guard.x > rotation_point.x {

                    find_or_add(found_locations, key);
                    count += 1;
                }
            case .WEST;
                new := Vector2_s16.{ guard.x - 1, guard.y };
                key := to_key(new);

                if table_contains(found_locations, key) == false
                && guard.x == rotation_point.x
                && guard.y > rotation_point.y {

                    find_or_add(found_locations, key);
                    count += 1;
                }
        }
    }

    return count;
}

parse_map :: (text: string) -> Map, Guard {
    map: Map = ---;
    guard: Guard;

    lines := split_newlines(text);
    lines.count -= 1;

    map.height = xx lines.count;
    map.width = xx lines[0].count;

    map.cells = NewArray(map.width * map.height, bool);

    for line, y: lines {
        for char, x: line {
            if char == {
                case #char "^";
                    guard.direction = .NORTH;
                    guard.x = xx x;
                    guard.y = xx y;
                case #char ">";
                    guard.direction = .EAST;
                    guard.x = xx x;
                    guard.y = xx y;
                case #char "v";
                    guard.direction = .SOUTH;
                    guard.x = xx x;
                    guard.y = xx y;
                case #char "<";
                    guard.direction = .WEST;
                    guard.x = xx x;
                    guard.y = xx y;

                case #char "#";
                    map.cells[map.width * y + x] = true;
            }
        }
    }

    return map, guard;
}

guard_step :: (using guard: *Guard, map: Map) -> outside_map: bool {
    is_outside_map :: (using map: Map, x: s16, y: s16) -> bool {
        return x < 0
            || x >= width
            || y < 0
            || y >= height;
    }

    is_obstructed :: (using map: Map, x: s16, y: s16) -> bool {
        if is_outside_map(map, x, y) return false;

        return cells[width * y + x];
    }

    if is_outside_map(map, x, y) return true;

    while true {
        if #complete direction == {
            case .NORTH;
                if is_obstructed(map, x, y - 1) {
                    direction = .EAST;
                    continue;
                }
            case .EAST;
                if is_obstructed(map, x + 1, y) {
                    direction = .SOUTH;
                    continue;
                }
            case .SOUTH;
                if is_obstructed(map, x, y + 1) {
                    direction = .WEST;
                    continue;
                }
            case .WEST;
                if is_obstructed(map, x - 1, y) {
                    direction = .NORTH;
                    continue;
                }
        }
        break;
    }

    if #complete direction == {
        case .NORTH; y -= 1;
        case .EAST;  x += 1;
        case .SOUTH; y += 1;
        case .WEST;  x -= 1;
    }

    return is_outside_map(map, x, y);
}

#import "File";
#import "Basic";
#import "String";
#import "AoC_Utils";
#import "Hash_Table";
