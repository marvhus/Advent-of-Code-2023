/* =========================================================================
 * This is my day 13 solution for Advent of Code 2024.
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
    run("13/test.txt", part_1);
    run("13/input.txt", part_1);

//    print("=== Part 2 ===\n");
//    run("13/test.txt", part_2);
//    run("13/input.txt", part_2);
}

part_1 :: (path: string) {
    contents, success := read_entire_file(path);
    assert(success);

    result: u64;

    games := parse(contents);
    for game: games {
        tokens, can_be_reached := find_minimum_tokens(game);
        if can_be_reached then result += tokens;
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
Game :: struct {
    delta_a, delta_b: Location;
    goal: Location;
}

find_minimum_tokens :: (game: Game) -> (tokens: u64, can_be_reached: bool) {
    tokens: u64 = 0xFFFFFFFFFFFFFFFF;
    can_be_reached := false;

    for a: 0..100 {
        for b: 0..100 {
            x := (game.delta_a.x * a) + (game.delta_b.x * b);
            y := (game.delta_a.y * a) + (game.delta_b.y * b);
            if x != game.goal.x || y != game.goal.y then continue;

            price := cast(u64) ((a * 3) + b);
            if price < tokens {
                tokens = price;
                can_be_reached = true;
            }
        }
    }

    return tokens, can_be_reached;
}

parse :: (text: string) -> [..]Game {
    extract_coordinate :: (text: string, prefix: string) -> int {
        start := find_index_from_left(text, prefix) + prefix.count;
        assert(start > prefix.count);

        substring := string.{ data = text.data + start, count = text.count - start };

        number, success := string_to_int(substring, 10, int);
        assert(success, tprint("text : '%', substring : '%', start : %, prefix : '%'\n",
            text, substring, start, prefix));

        return number;
    }

    games: [..]Game;

    current_game: Game;
    for line: split_newlines(text) {
        BUTTON_A :: "Button A: ";
        BUTTON_B :: "Button B: ";
        PRIZE    :: "Prize: ";

        if begins_with(line, BUTTON_A) {
            current_game.delta_a.x = extract_coordinate(line, "X+");
            current_game.delta_a.y = extract_coordinate(line, "Y+");
            continue;
        }

        if begins_with(line, BUTTON_B) {
            current_game.delta_b.x = extract_coordinate(line, "X+");
            current_game.delta_b.y = extract_coordinate(line, "Y+");
            continue;
        }

        if begins_with(line, PRIZE) {
            current_game.goal.x = extract_coordinate(line, "X=");
            current_game.goal.y = extract_coordinate(line, "Y=");

            array_add(*games, current_game);
            current_game = Game.{};
            continue;
        }
    }

    return games;
}

#import "File";
#import "String";
#import "Basic";
#import "AoC_Utils";
