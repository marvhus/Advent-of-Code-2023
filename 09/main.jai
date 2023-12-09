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
	run("09/test.txt", part_1);
	run("09/input.txt", part_1);
	
	print("=== Part 2 ===\n");
	run("09/test.txt", part_2);
	run("09/input.txt", part_2);
}

parse_line :: (line : string) -> []s64 {
	nums : [..]s64;
	for num_str : split(line, " ") {
		num, has_num := string_to_int(num_str, 10, s64); // this handles negative numbers too.
		assert(has_num);
		array_add(*nums, num);
	}
	return nums;
}

solve_line :: (
	nums : []s64,
	func : #type ([]s64, s64) -> (s64)
) -> s64 {
	all_zero :: (ns : []s64) -> bool {
		for n : ns if n != 0 return false;
		return true;
	}
	all_nums : [..][]s64;
	{
		array_add(*all_nums, nums);
		current_nums : [..]s64;
		idx := 0;
		while true {
			for 0..all_nums[idx].count-2 {
				n1 := all_nums[idx][it];
				n2 := all_nums[idx][it + 1];
				diff := n2 - n1;
				array_add(*current_nums, diff);
			}
			if all_zero(current_nums) break;
			array_add(*all_nums, array_copy(current_nums));
			array_reset(*current_nums);
			idx += 1;
		}
		array_add(*all_nums, array_copy(current_nums));
	}
	extrapolated : s64;
	{
		idx := all_nums.count-2;
		while idx >= 0 {
			extrapolated = func(
				all_nums[idx],
				extrapolated
			);
			idx -= 1;
		}
	}
	return extrapolated;
}

part_1 :: (path: string) {
	func :: (xs : []s64, y : s64) -> s64 {
		return xs[xs.count-1] + y;
	}

	contents, success := read_entire_file(path);
	assert(success);

	total : s64;
	for line : split_newlines(contents) {
		if line.count == 0 continue;
		nums := parse_line(line);
		res := solve_line(nums, func);
		total += res;
	}
	print("Result: %\n", total);
}

part_2 :: (path: string) {
	func :: (xs : []s64, y : s64) -> s64 {
		assert(xs.count > 0);
		return xs[0] - y;
	}

	contents, success := read_entire_file(path);
	assert(success);

	total : s64;
	for line : split_newlines(contents) {
		if line.count == 0 continue;
		nums := parse_line(line);
		res := solve_line(nums, func);
		total += res;
	}
	print("Result: %\n", total);
}

#import "File";
#import "String";
#import "Basic";
#import "AoC_Utils";
