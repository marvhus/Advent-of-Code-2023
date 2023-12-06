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
	// part_1("06/test.txt");
	part_1("06/input.txt");
	// part_2("06/test.txt");
	part_2("06/input.txt");
}

Game :: struct {
	time_ms     : u32;
	dist_mm : u32;
}

strip_spaces :: (str : string) -> string {
	tmp_str := str;
	while tmp_str.count > 0 && is_space(tmp_str[0]) {
		tmp_str.count -= 1;
		tmp_str.data += 1;
	}
	return tmp_str;
}

parse_num_list_2 :: (list : string) -> u64 {
	sb : String_Builder;
	init_string_builder(*sb);
	// prepare
	list_str := strip_spaces(list);
	for split(list_str, "  ") {
		list_str_2 := strip_spaces(it);
		if list_str_2.count == 0 continue; // we don't need spaces
		append(*sb, list_str_2);
	}
	num, has_num := string_to_int(builder_to_string(*sb), 10, u64);
	assert(has_num);
	return num;
}

parse_num_list :: (list : string) -> []u32 {
	res : [..]u32;
	// prepare
	time_list_str := strip_spaces(list);
	for time_str : split(time_list_str, "  ") {
		// ... it may have spaces
		time_str_2 := strip_spaces(time_str);
		if time_str_2.count == 0 continue; // don't parse spaces
		num, has_num := string_to_int(time_str_2, 10, u32);
		assert(has_num, sprint("missing number. list : '%', str : '%'", list, time_str_2));
		array_add(*res, num);
	}
	return res;
}

part_1 :: (path: string) {
	print("PART 1!\n");
	contents, success := read_entire_file(path);
	assert(success);

	times : []u32;
	dists : []u32;
	for line : split_newlines(contents) {
		if line.count == 0 continue;
		if begins_with(line, "Time:") {
			success, _, list := split_from_left(line, "Time:");
			times = parse_num_list(list);
		} else if begins_with(line, "Distance:") {
			success, _, list := split_from_left(line, "Distance:");
			dists = parse_num_list(list);
		}
	}
	assert(times.count == dists.count);
	assert(times.count + dists.count > 0);

	total : u32;
	for 0..times.count-1 {
		possible : u32;
		time := times[it];
		dist := dists[it];
		for 1..time-1 {
			if it * (time - it) > dist then possible += 1;
		}
		if possible > 0 {
			if total == 0 then total = possible;
			else total *= possible;
		}
	}
	print("TOTAL %\n", total);
}

part_2 :: (path: string) {
	print("PART 2\n");
	contents, success := read_entire_file(path);
	assert(success);

	time : u64;
	dist : u64;
	for line : split_newlines(contents) {
		if line.count == 0 continue;
		if begins_with(line, "Time:") {
			success, _ , list := split_from_left(line, "Time:");
			time = parse_num_list_2(list);
		} else if begins_with(line, "Distance:") {
			success, _, list := split_from_left(line, "Distance:");
			dist = parse_num_list_2(list);
		}
	}
	possible : u32;
	for 1..time-1 {
		if it * (time - it) > dist then possible += 1;
	}
	print("POSSIBLE %\n", possible);
}

#import "File";
#import "String";
#import "Basic";
#import "AoC_Utils";
