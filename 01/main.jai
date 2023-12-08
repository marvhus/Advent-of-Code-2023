/* =========================================================================
 * This is template.jai
 * Copyright (C) 2023  marvhus
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
	run("01/test.txt", part_1);
	run("01/test2.txt", part_1);
	run("01/input.txt", part_1);
	
	print("=== Part 2 ===\n");
	run("01/test.txt", part_2);
	run("01/input.txt", part_2);
}

Direction :: enum {
	Up;
	Down;
}

parse :: (input : string) -> []Direction {
	directions : [..]Direction;
	for 0..input.count-1 {
		if input[it] == {
			case #char "("; array_add(*directions, .Up);
			case #char ")"; array_add(*directions, .Down);
		}
	}

	return directions;
}

part_1 :: (path: string) {
	contents, success := read_entire_file(path);
	assert(success);

	floor : int;
	directions := parse(contents);
	for direction : directions if direction == {
		case .Up; floor += 1;
		case .Down; floor -= 1;
	}
	print("Result: %\n", floor);
}

part_2 :: (path: string) {
	contents, success := read_entire_file(path);
	assert(success);

	// @TODO(martin): Implement Day 2.
}

#import "File";
#import "String";
#import "Basic";
#import "AoC_Utils";
