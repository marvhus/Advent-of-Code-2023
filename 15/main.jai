/* =========================================================================
 * This is my day 15 solution for Advent of Code 2024
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
    run("15/test.txt", part_1);
    run("15/input.txt", part_1);

//    print("=== Part 2 ===\n");
//    run("15/test.txt", part_2);
//    run("15/input.txt", part_2);
}

part_1 :: (path: string) {
    contents, success := read_entire_file(path);
    assert(success);

    map := parse(contents);
    simulate(*map);
    //print_map(map);
    result := calculate_sum(map);

    print("Result : %\n", result);
}

part_2 :: (path: string) {
    contents, success := read_entire_file(path);
    assert(success);

    // @TODO(martin): Implement Part 2.
}

Tile :: enum {
    EMPTY :: 0;
    WALL;
    BOX;
    ROBOT;
}

Vector2i :: struct {
    x, y: int;
}
operator + :: (a: Vector2i, b: Vector2i) -> Vector2i {
    return Vector2i.{
        x = a.x + b.x,
        y = a.y + b.y,
    };
}

Map :: struct {
    width, height: int;
    tiles: []Tile;
    moves: [..]Vector2i;
    robots: [..]Vector2i;
}

print_map :: (using map: Map) {
    for y: 0..height - 1 {
        for x: 0..width - 1 {
            if tiles[width * y + x] == {
                case .EMPTY; print(".");
                case .WALL;  print("#");
                case .BOX;   print("O");
                case .ROBOT; print("@");
            }
        }
        print("\n");
    }
}

calculate_sum :: (using map: Map) -> int {
    sum: int;

    for y: 0..height - 1 {
        for x: 0..width - 1 {
            tile := tiles[width * y + x];
            if tile != .BOX continue;

            sum += (100 * y) + x;
        }
    }

    return sum;
}

simulate :: (using map: *Map) {
    prepare_move :: (using map: *Map, position: Vector2i, delta: Vector2i) -> can_move: bool {
        if position.x < 0
        || position.x >= width
        || position.y < 0
        || position.y >= height {
            return false;
        }
        tiles_index  := width * position.y + position.x;
        current_tile := tiles[tiles_index];

        if current_tile == .WALL  then return false;
        if current_tile == .EMPTY then return true;

        new_position := position + delta;
        can_move := prepare_move(map, new_position, delta);
        if can_move == false then return false;

        tiles[width * new_position.y + new_position.x] = current_tile;
        tiles[tiles_index] = .EMPTY;

        if current_tile == .ROBOT {
            for *robot: robots {
                if robot.x != new_position.x
                || robot.y != new_position.y {
                    continue;
                }

                robot.* = new_position + delta;
            }
        }

        return true;
    }

    for move: moves {
        //print_map(map);
        for *robot: robots {
            can_move := prepare_move(map, robot, move);
            if can_move == false then continue;

            tiles[width * robot.y + robot.x] = .EMPTY;

            robot.* = robot.* + move;
            tiles[width * robot.y + robot.x] = .ROBOT;
        }
    }
}

parse :: (text: string) -> Map {
    map: Map;

    success, map_section, moves_section := split_from_left(text, "\n\n");
    assert(success, "Failed to separate map section and moves section");

    map_lines := split_newlines(map_section);
    map.height = map_lines.count;
    map.width  = map_lines[0].count;

    { // Parse map section.
        map.tiles = NewArray(map.width * map.height, Tile);
        for line, y: map_lines {
            for char, x: line {
                tile: Tile;
                if char == {
                    case #char "#"; map.tiles[map.width * y + x] = .WALL;
                    case #char "O"; map.tiles[map.width * y + x] = .BOX;
                    case #char "@";
                        map.tiles[map.width * y + x] = .ROBOT;
                        array_add(*map.robots, Vector2i.{ x = x, y = y });
                }
            }
        }
    }

    { // Parse moves section.
        array_reserve(*map.moves, moves_section.count);
        for char: moves_section {
            if char == {
                case #char "^"; array_add(*map.moves, Vector2i.{ x =  0, y = -1 });
                case #char "v"; array_add(*map.moves, Vector2i.{ x =  0, y =  1 });
                case #char "<"; array_add(*map.moves, Vector2i.{ x = -1, y =  0 });
                case #char ">"; array_add(*map.moves, Vector2i.{ x =  1, y =  0 });
            }
        }
    }

    return map;
}

#import "File";
#import "String";
#import "Basic";
#import "AoC_Utils";
