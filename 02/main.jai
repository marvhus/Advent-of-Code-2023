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
	run("02/test.txt", part_1);
	run("02/input.txt", part_1);
	
	print("=== Part 2 ===\n");
	run("02/test.txt", part_2);
	run("02/input.txt", part_2);
}

Size :: struct {
	l, w, h : u32; // length width height
}

parse :: (input : string) -> []Size {
	sizes : [..]Size;
	for line : split_newlines(input) {
		if line.count == 0 continue;
		nums : [3]u32;
		for num_str, i : split(line, "x") {
			assert(i < 3);
			num, has_num := string_to_int(num_str, 10, u32);
			assert(has_num);
			nums[i] = num;
		}
		array_add(*sizes, .{nums[0], nums[1], nums[2]});
	}
	return sizes;
}

part_1 :: (path: string) {
	contents, success := read_entire_file(path);
	assert(success);

	total : u32;
	for size : parse(contents) {
		side_1 := size.l * size.w;
		side_2 := size.w * size.h;
		side_3 := size.h * size.l;
		smallest := min(side_1, min(side_2, side_3));
		total += side_1 * 2 + side_2 * 2 + side_3 * 2 + smallest;
	}
	print("Result: %\n", total);
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
#import "Math";
