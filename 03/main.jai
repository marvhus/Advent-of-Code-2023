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
	run("03/test.txt", part_1);
	run("03/test2.txt", part_1);
	run("03/test3.txt", part_1);
	run("03/input.txt", part_1);
	
	print("=== Part 2 ===\n");
	run("03/test.txt", part_2);
	run("03/input.txt", part_2);
}

Direction :: enum {
	North; // ^
	South; // v
	East; // >
	West; // <
}
Position :: struct {
	x, y : s32;
}

pos_to_str :: (pos : Position) -> string {
	return sprint("%:%", pos.x, pos.y);
}

parse :: (input : string) -> []Direction {
	directions : [..]Direction;
	for 0..input.count-1 if input[it] == {
		case #char "^";	array_add(*directions, .North);
		case #char "v";	array_add(*directions, .South);
		case #char ">";	array_add(*directions, .East);
		case #char "<"; array_add(*directions, .West);
	}
	return directions;
}

part_1 :: (path: string) {
	contents, success := read_entire_file(path);
	assert(success);

	houses : Table(string, bool);
	pos := Position.{0, 0};
	table_add(*houses, pos_to_str(pos), true);
	for direction : parse(contents) {
		if direction == {
			case .North; pos.y += 1;
			case .South; pos.y -= 1;
			case .East; pos.x += 1;
			case .West; pos.x -= 1;
		}
		id := pos_to_str(pos);
		if !table_contains(*houses, id) {
			table_add(*houses, id, true);
		}
	}
	print("Result: %\n", houses.count);
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
#import "Hash_Table";
