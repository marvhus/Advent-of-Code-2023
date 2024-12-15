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
//    print("=== Part 1 ===\n");
//    run("15/test.txt", part_1);
//    run("15/input.txt", part_1);

    print("=== Part 2 ===\n");
//    run("15/test.txt", part_2);
    run("15/input.txt", part_2);
}

part_1 :: (path: string) {
    contents, success := read_entire_file(path);
    assert(success);

    map := parse(contents);
    for move: map.moves {
        simulate_move(*map, to_delta(move));
    }
    //print_map(map);
    result := calculate_sum(map);

    print("Result : %\n", result);
}

part_2 :: (path: string) {
    contents, success := read_entire_file(path);
    assert(success);

    map := parse(contents, is_part_2 = true);
    print_map(map);
    print("-------------------\n");
    for move: map.moves {
        simulate_move(*map, to_delta(move), is_part_2 = true);

        print("Move: %\n", move);
        print_map(map);
        print("-------------------\n");
    }
    result := calculate_sum(map);

    print("Result : %\n", result);
}

Tile :: enum {
    EMPTY :: 0;
    WALL;
    BOX;
    ROBOT;

    BOX_LEFT;
    BOX_RIGHT;
}

Direction :: enum {
    UP;
    DOWN;
    LEFT;
    RIGHT;
}
to_delta :: (direction: Direction) -> Vector2i {
    if direction == {
        case .UP;    return Vector2i.{ x =  0, y = -1 };
        case .DOWN;  return Vector2i.{ x =  0, y = +1 };
        case .LEFT;  return Vector2i.{ x = -1, y =  0 };
        case .RIGHT; return Vector2i.{ x = +1, y =  0 };
    }
    assert(false);
    return Vector2i.{ x = 0, y = 0 };
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
operator - :: (a: Vector2i, b: Vector2i) -> Vector2i {
    return Vector2i.{
        x = a.x - b.x,
        y = a.y - b.y,
    };
}

Map :: struct {
    width, height: int;
    tiles: []Tile;
    moves: [..]Direction;
    robot: Vector2i;
}

print_map :: (using map: Map) {
    for y: 0..height - 1 {
        for x: 0..width - 1 {
            if tiles[width * y + x] == {
                case .EMPTY; print(".");
                case .WALL;  print("#");
                case .BOX;   print("O");
                case .ROBOT; print("@");

                case .BOX_LEFT;  print("[");
                case .BOX_RIGHT; print("]");
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

            if tile == .BOX
            || tile == .BOX_LEFT {
                sum += (100 * y) + x;
            }
        }
    }

    return sum;
}

recursive_check :: (using map: Map, position: Vector2i, delta: Vector2i, $is_part_2 := false) -> success: bool {
    next_position := position + delta;

    if next_position.x < 0
    || next_position.x >= width
    || next_position.y < 0
    || next_position.y >= height {
        return false;
    }

    #if is_part_2 { // === PART 2 ===
        right_position := next_position;
        left\_position := next_position - .{ x = 1, y = 0 } ;

        right_tile := tiles[width * right_position.y + right_position.x];
        left\_tile := tiles[width * left\_position.y + left\_position.x];

        if right_tile == .EMPTY && left_tile == .EMPTY then return true;
        if right_tile == .WALL  || left_tile == .WALL  then return false;

        if right_tile == .BOX_RIGHT {
            return recursive_check(map, right_position, delta, is_part_2 = true);
        }

        can_move: bool;
        if right_tile == .BOX_LEFT then can_move ||= recursive_check(map, right_position + .{ x = +1, y = 0 }, delta, is_part_2 = true);
        if left_tile == .BOX_RIGHT then can_move ||= recursive_check(map, right_position + .{ x = -1, y = 0 }, delta, is_part_2 = true);

        return can_move;
    } else { // === PART 1 ===
        next_tile := tiles[width * next_position.y + next_position.x];

        if next_tile == .EMPTY then return true;
        if next_tile == .WALL  then return false;

        return recursive_check(map, next_position, delta);
    }
}

recursive_move :: (using map: *Map, position: Vector2i, delta: Vector2i, $is_part_2 := false) {
    next_position := position + delta;

    if next_position.x < 0
    || next_position.x >= width
    || next_position.y < 0
    || next_position.y >= height {
        return;
    }

    #if is_part_2 { // === PART 2 ===
        right_position := next_position;
        left\_position := next_position - .{ x = 1, y = 0 } ;

        right_index := width * right_position.y + right_position.x;
        left\_index := width * left\_position.y + left\_position.x;

        right_tile := tiles[right_index];
        left\_tile := tiles[left\_index];

        // Just move and exit if space is empty.
        if right_tile == .EMPTY && left_tile == .EMPTY {
            tiles[right_index] = .BOX_RIGHT;
            tiles[left\_index] = .BOX_LEFT;
            right_index = width * position.y + position.x;
            left\_index = width * position.y + position.x - 1;
            tiles[right_index] = .EMPTY;
            tiles[left\_index] = .EMPTY;

            return;
        }

        // Aligned. We can just move it up.
        if right_tile == .BOX_RIGHT {
            recursive_move(map, next_position, delta, is_part_2 = true);

            tiles[right_index] = .BOX_RIGHT;
            tiles[left\_index] = .BOX_LEFT;
            right_index = width * position.y + position.x;
            left\_index = width * position.y + position.x - 1;
            tiles[right_index] = .EMPTY;
            tiles[left\_index] = .EMPTY;

            return;
        }

        // Not aligned.

        // Box offset to the right.
        if right_tile == .BOX_LEFT then recursive_move(map, next_position + .{ x = 1, y = 0 }, delta, is_part_2 = true);
        // Box offset to the left.
        if left_tile == .BOX_RIGHT then recursive_move(map, next_position - .{ x = 1, y = 0 }, delta, is_part_2 = true);

        tiles[right_index] = .BOX_RIGHT;
        tiles[left\_index] = .BOX_LEFT;
        right_index = width * position.y + position.x;
        left\_index = width * position.y + position.x - 1;
        tiles[right_index] = .EMPTY;
        tiles[left\_index] = .EMPTY;

        return;
    } else { // === PART 1 ===
        next_index := width * next_position.y + next_position.x;
        next_tile  := tiles[next_index];

        // Just move immediatly if possible.
        if next_tile == .EMPTY {
            tiles[next_index] = .BOX;
            next_index = width * position.y + position.x;
            tiles[next_index] = .EMPTY;

            return;
        }

        recursive_move(map, next_position, delta);

        tiles[next_index] = .BOX;
        next_index = width * position.y + position.x;
        tiles[next_index] = .EMPTY;

        return;
    }
} 

simulate_move :: (using map: *Map, delta: Vector2i, $is_part_2 := false) {
    next_position := robot + delta;
    next_index := width * next_position.y + next_position.x;
    next_tile  := tiles[next_index];

    #if is_part_2 { // === PART 2 ===
        // Robot can just freely move.
        if next_tile == .EMPTY {
            current_index := width * robot.y + robot.x;
            tiles[current_index] = .EMPTY;

            robot = next_position;
            tiles[next_index] = .ROBOT;

            return;
        }

        // Robot is obstructed by box.
        if next_tile == .BOX_LEFT || next_tile == .BOX_RIGHT {
            start_tile := next_tile;

            // Moving on the X-axis
            // Everything can just slide to the side.
            if delta.y == 0 {
                new_position := next_position + delta;
                new_index    := width * new_position.y + new_position.x;
                new_tile     := tiles[new_index];

                while new_tile == .BOX_RIGHT || new_tile == .BOX_LEFT {
                    new_position = new_position + delta;
                    new_index    = width * new_position.y + new_position.x;
                    new_tile     = tiles[new_index];
                }

                if new_tile == .EMPTY {
                    if start_tile == .BOX_LEFT then tiles[new_index] = .BOX_RIGHT;
                                               else tiles[new_index] = .BOX_LEFT;
                    current_index := width * robot.y + robot.x;
                    tiles[current_index] = .EMPTY;
                    robot = next_position;
                    tiles[next_index] = .ROBOT;

                    step := (start_tile == .BOX_LEFT);
                    new_position = new_position - delta;
                    new_index    = width * new_position.y + new_position.x;
                    new_tile     = tiles[new_index];
                    while new_tile != .ROBOT {
                        if step then tiles[new_index] = .BOX_LEFT;
                                else tiles[new_index] = .BOX_RIGHT;
                        step = ! step;

                        new_position = new_position - delta;
                        new_index    = width * new_position.y + new_position.x;
                        new_tile     = tiles[new_index];
                    }
                }

                return;
            }

            // Moving on the Y-axis
            can_move: bool;
            if next_tile == .BOX_RIGHT then can_move = recursive_check(map, next_position                    , delta, is_part_2 = true);
                                       else can_move = recursive_check(map, next_position + .{ x = 1, y = 0 }, delta, is_part_2 = true);
            if can_move == false then return;

            if next_tile == .BOX_RIGHT then recursive_move(map, next_position                    , delta, is_part_2 = true);
                                       else recursive_move(map, next_position + .{ x = 1, y = 0 }, delta, is_part_2 = true);

            current_index := width * robot.y + robot.x;
            tiles[current_index] = .EMPTY;

            robot = next_position;
            tiles[next_index] = .ROBOT;
        }
    } else { // === PART 1 ===
        // Robot can just freely move.
        if next_tile == .EMPTY {
            current_index := width * robot.y + robot.x;
            tiles[current_index] = .EMPTY;

            robot = next_position;
            tiles[next_index] = .ROBOT;

            return;
        }

        // Robot is obstructed by box.
        if next_tile == .BOX {
            if recursive_check(map, next_position, delta) then return;
            recursive_move(map, next_position, delta);

            current_index := width * robot.y + robot.x;
            tiles[current_index] = .EMPTY;

            robot = next_position;
            tiles[next_index] = .ROBOT;

            return;
        }
    }
}

parse :: (text: string, $is_part_2 := false) -> Map {
    map: Map;

    success, map_section, moves_section := split_from_left(text, "\n\n");
    assert(success, "Failed to separate map section and moves section");

    #if is_part_2 { // Parse map section. (Part 2)
        map_lines := split_newlines(map_section);
        map.height = map_lines.count;
        map.width  = map_lines[0].count * 2;
        map.tiles = NewArray(map.width * map.height, Tile);

        for line, y: map_lines {
            for char, x: line {
                index := map.width * y + x * 2;
                if char == {
                    case #char "@";
                        map.tiles[index    ] = .ROBOT;
                        map.tiles[index + 1] = .EMPTY;

                        map.robot.x = x * 2;
                        map.robot.y = y;
                    case #char "#";
                        map.tiles[index    ] = .WALL;
                        map.tiles[index + 1] = .WALL;
                    case #char "O";
                        map.tiles[index    ] = .BOX_LEFT;
                        map.tiles[index + 1] = .BOX_RIGHT;
                    case;
                        map.tiles[index    ] = .EMPTY;
                        map.tiles[index + 1] = .EMPTY;
                }
            }
        }
    } else {
        map_lines := split_newlines(map_section);
        map.height = map_lines.count;
        map.width  = map_lines[0].count;
        map.tiles = NewArray(map.width * map.height, Tile);

        for line, y: map_lines {
            for char, x: line {
                index := map.width * y + x;
                if char == {
                    case #char "@";
                        map.tiles[index] = .ROBOT;

                        map.robot.x = x;
                        map.robot.y = y;
                    case #char "#";
                        map.tiles[index] = .WALL;
                    case #char "O";
                        map.tiles[index] = .BOX;
                    case;
                        map.tiles[index] = .EMPTY;
                }
            }
        }
    }

    { // Parse moves section.
        array_reserve(*map.moves, moves_section.count);
        for char: moves_section {
            if char == {
                case #char "^"; array_add(*map.moves, Direction.UP   );
                case #char "v"; array_add(*map.moves, Direction.DOWN );
                case #char "<"; array_add(*map.moves, Direction.LEFT );
                case #char ">"; array_add(*map.moves, Direction.RIGHT);
            }
        }
    }

    return map;
}

#import "File";
#import "String";
#import "Basic";
#import "AoC_Utils";
