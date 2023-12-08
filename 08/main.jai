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

main :: () {
	// part_1("08/test.txt");
	// part_1("08/test2.txt");
	part_1("08/input.txt");
}

LeftRight :: enum {
	Left;
	Right;
}
Node :: struct {
	left, right : string;
}
Map :: struct {
	directions : []LeftRight;

	nodes : Table(string, Node);
}

parse_map :: (text : string) -> map: Map {
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

	return .{directions, nodes};
}

part_1 :: (path: string) {
	print("Part 1.\n");
	contents, success := read_entire_file(path);
	assert(success);

	map := parse_map(contents);

	steps : u32;
	current := "AAA";
	found := false;
	while !found {
		for direction : map.directions {
			if current == "ZZZ" {
				found = true;
				break;
			}
			node, success := table_find(*map.nodes, current);
			assert(success);
			print("%, %\n", current, node);
			if direction == {
				case .Left; current = node.left;
				case .Right; current = node.right;
			}
			steps += 1;
		}
	}
	print("Found % in % steps.\n", current, steps);
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
