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

run :: (path : string, func : #type (string) -> ()) {
	print("Running with '%'\n", path);
	func(path);
}

main :: () {
	print("=== Part 1 ===\n");
	run("08/test.txt", part_1);
	run("08/test2.txt", part_1);
	run("08/input.txt", part_1);

	print("=== Part 2 ===\n");
	run("08/test3.txt", part_2);
	run("08/input.txt", part_2);
}

LeftRight :: enum {
	Left;
	Right;
}
Node :: struct {
	left, right : string;
}

parse_map :: (text : string) -> directions: []LeftRight, nodes: Table(string, Node) {
	success, directions_str, node_lines := split_from_left(text, "\n\n");
	
	directions : [..]LeftRight;
	{
		for 0..directions_str.count-1 {
			chr := directions_str[it];
			if chr == {
				case #char "L"; array_add(*directions, .Left);
				case #char "R"; array_add(*directions, .Right);
				case; assert(false, sprint("Invalid direction '%'", chr));
			}
		}
	}

	nodes : Table(string, Node);
	{
		for line : split_newlines(node_lines) {
			if line.count == 0 continue;
			success, name, pair := split_from_left(line, " = ");
			
			// maybe check this, and not do it blindly
			pair.data += 1; // skip over first (
			pair.count -= 2; // lower count because skipping (, lower it one more to skip the last one )

			success_1, left_name, right_name := split_from_left(pair, ", ");

			table_add(*nodes, name, .{left_name, right_name});
		}
	}

	return directions, nodes;
}

solve :: (
	directions : []LeftRight,
	nodes : Table(string, Node),
	start : string,
	check : #type (string) -> bool
) -> u64 {
	count : u64;
	current := start;
	while true {
		node, success := table_find(*nodes, current);
		assert(success);
		if directions[count % xx directions.count] == {
			case .Left; current = node.left;
			case .Right; current = node.right;
		}
		count += 1;
		if check(current) break;
	}
	return count;
}

part_1 :: (path: string) {
	contents, success := read_entire_file(path);
	assert(success);

	check :: (str : string) -> bool {
		return str == "ZZZ";
	}
	
	directions, nodes := parse_map(contents);
	steps := solve(directions, nodes, "AAA", check);

	print("Result: %\n", steps);
}

part_2 :: (path: string) {
	contents, success := read_entire_file(path);
	assert(success);

	gcd :: (a : u64, b : u64) -> u64 {
		if b == 0 return a;
		return gcd(b, a % b);
	}
	lcm :: (a : u64, b : u64) -> u64 {
		return a / gcd(a, b) * b;
	}
	fold_lcm :: (value : u64, values : []u64) -> u64 {
		res := value;
		for val : values {
			res = lcm(res, val);
		}
		return res;
	}
	check :: (str : string) -> bool {
		return ends_with(str, "Z");
	}
	
	directions, nodes := parse_map(contents);
	counts : [..]u64;
	for _, key : nodes {
		if !ends_with(key, "A") continue;
		count := solve(directions, nodes, key, check);
		array_add(*counts, count);
	}
	
	steps := fold_lcm(1, counts);
	print("Result: %\n", steps);
}

#import "File";
#import "String";
#import "Basic";
#import "AoC_Utils";
#import "Hash_Table";
