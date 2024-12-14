/* =========================================================================
 * This is my day 14 solution for Advent of Code 2024.
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
    run("14/test.txt", part_1);
    run("14/input.txt", part_1);

    print("=== Part 2 ===\n");
//    run("14/test.txt", part_2); // Part 2 doesn't have a test solution.
    run("14/input.txt", part_2);
}

part_1 :: (path: string) {
    contents, success := read_entire_file(path);
    assert(success);

    robots, top_left, bottom_right := parse(contents);
    width  := bottom_right.x - top_left.x + 1;
    height := bottom_right.y - top_left.y + 1;

    simulate(robots, width, height, 100);
    result := calculate_safety_factor(robots, width, height);

    print("Result : %\n", result);
}

part_2 :: (path: string) {
    contents, success := read_entire_file(path);
    assert(success);

    robots, top_left, bottom_right := parse(contents);
    width  := bottom_right.x - top_left.x + 1;
    height := bottom_right.y - top_left.y + 1;
    duration: u64;

    while true {
        defer duration += 1;
        simulate(robots, width, height, 1);

        str := to_string(robots, width, height);
        defer free(str.data);

        if contains(str, "##########") then break; // Check for a border.
    }

    print("Result : %\n", duration);
}

Vector2i :: struct {
    x, y: int;
}
Robot :: struct {
    position, velocity: Vector2i;
}

to_string :: (robots: []Robot, width: int, height: int) -> string {
    str := string.{
        data  = alloc(width * height),
        count = width * height,
    };
    for *char: str { char.* = #char " "; }

    for robot: robots {
        str[width * robot.position.y + robot.position.x] = #char "#";
    }

    return str;
}

print_map :: (robots: []Robot, width: int, height: int, spacing := ".") {
    map := NewArray(width * height, u8);
    for *it: map { it.* = 0; }

    for robot: robots {
        x := robot.position.x;
        y := robot.position.y;

        map[width * y + x] += 1;
    }

    for y: 0..height-1 {
        for x: 0..width-1 {
            cell := map[width * y + x];
            if cell == 0 then print(spacing);
                         else print("%", cell);
        }
        print("\n");
    }
}

calculate_safety_factor :: (robots: []Robot, width: int, height: int) -> int {
    top_left_count, top_right_count, bottom_left_count, bottom_right_count: int;

    middle_x := width  / 2;
    middle_y := height / 2;

    if width  % 2 == 1 then middle_x += 1;
    if height % 2 == 1 then middle_y += 1;

    for robot: robots {
        // in case top left is not 0,0 but for example 1,1

        x := robot.position.x;
        y := robot.position.y;

        // Ignore robots in the middle.
        if x == middle_x continue;
        if y == middle_y continue;

        if y < middle_y {
            if x < middle_x then top_left_count  += 1;
                            else top_right_count += 1;
        } else {
            if x < middle_x then bottom_left_count  += 1;
                            else bottom_right_count += 1;
        }
    }

    return top_left_count * top_right_count * bottom_left_count * bottom_right_count;
}

simulate :: (robots: []Robot, width: int, height: int, duration: int) {
    for *robot: robots {
        robot.position.x += robot.velocity.x * xx duration;
        robot.position.y += robot.velocity.y * xx duration;

        while robot.position.x >= width { robot.position.x -= width; }
        while robot.position.x <  0     { robot.position.x += width; }

        while robot.position.y >= height { robot.position.y -= height; }
        while robot.position.y <  0      { robot.position.y += height; }
    }
}

parse :: (text: string) -> ([..]Robot, top_left: Vector2i, bottom_right: Vector2i) {
    lines := split_newlines(text);
    lines.count -= 1;

    robots: [..]Robot;
    top_left, bottom_right: Vector2i;
    first := true;

    for line: lines {
        robot: Robot;

        substring := string.{ data = line.data + 2, count = line.count - 2 };

        found, position, velocity := split_from_left(substring, " v=");
        assert(found);
        {
            found=, x, y := split_from_left(position, ",");
            assert(found);

            robot.position.x = string_to_int(x, 10, int);
            robot.position.y = string_to_int(y, 10, int);
        }
        {
            found=, x, y := split_from_left(velocity, ",");
            assert(found);

            robot.velocity.x = string_to_int(x, 10, int);
            robot.velocity.y = string_to_int(y, 10, int);
        }

        array_add(*robots, robot);

        if first {
            top_left.x = robot.position.x;
            top_left.y = robot.position.y;
            bottom_right.x = robot.position.x;
            bottom_right.y = robot.position.y;
            first = false;
            continue;
        }

        if robot.position.x < top_left.x then top_left.x = robot.position.x;
        if robot.position.y < top_left.y then top_left.y = robot.position.y;
        if robot.position.x > bottom_right.x then bottom_right.x = robot.position.x;
        if robot.position.y > bottom_right.y then bottom_right.y = robot.position.y;
    }


    return robots, top_left, bottom_right;
}

#import "Math";
#import "File";
#import "Basic";
#import "String";
#import "AoC_Utils";
#import "Hash_Table";
