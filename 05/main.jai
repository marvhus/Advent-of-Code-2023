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
	print("Part 1 Test:\n");
	part_1("05/test.txt");
	
	// print("Part 1 Input:\n");
	// part_1("05/input.txt");
}

Map :: struct {
	dest_start: s64;
	src_start: s64;
	length: s64;
}

Category :: struct {
	name : string;
	maps : [..]Map;
};

parse_almanac :: (text : string) -> seeds : []s64, categories : []Category {
	lines := split_newlines(text);

	seeds : []s64 = ---;
	categories : [..]Category;
	category : Category;
	first := true;
	
	for line : lines {
		if line.count == 0 continue;

		has_name, name, rest := split_from_left(line, ":");

		if has_name {
			if name == "seeds" {
				if is_space(rest[0]) { // trim
					rest.data += 1;
					rest.count -= 1;
				}

				nums := split_the_number_list(rest);
				seeds = array_copy(nums);
				continue;
			}
			
			if !first {
				array_add(*categories, copy_category(category));
			} else {
				first = false;
			}
			
			found_space, name_with_no_space := split_from_left(name, " ");
			assert(found_space);
			
			category.name = name_with_no_space;
			// @NOTE(martin): will this mess with the one we just stored???
			array_reset(*category.maps);
			continue;
		}

		nums := split_the_number_list(line);
		array_add(*category.maps, nums_to_map(nums));
	}
	array_add(*categories, category);

	assert(seeds.data != null); // can't have an almanac with no seeds
	return seeds, categories;
}

copy_category :: (old: Category) -> Category {
	new: Category;
	new.name = copy_string(old.name);
	for map : old.maps array_add(*new.maps, map);
	return new;
}

nums_to_map :: (nums: []s64) -> Map {
	assert(nums.count == 3);

	return .{
		dest_start = nums[0],
		src_start = nums[1],
		length = nums[2]
	};
}

split_the_number_list :: (number_list: string) -> [..]s64 {
	numbers : [..]s64;
	for str_num : split(number_list, " ") {
		// parsing non existant numbers would be stupid.
		if str_num.count == 0 continue;
		num, has_number := string_to_int(str_num, 10, s64);
		assert(has_number); // check your input.
		
		array_add(*numbers, num);
	}
	return numbers;
}

in_range :: (num : s64, start : s64, length : s64) -> bool {
	return num >= start && num < start + length;
}

part_1 :: (path: string) {
	contents, success := read_entire_file(path);
	assert(success);

	seeds, categories := parse_almanac(contents);

	lowest : s64 = 1 << 62;
	for seed : seeds {
		print("Seed: %\n", seed);
		value := seed;
		for category : categories {
			for map : category.maps if in_range(value, map.src_start, map.length) {
				value += map.dest_start - map.src_start;
				break;
			}
			print("\t% -- %\n", value, category);
		}
		print("\n");
		if value < lowest then lowest = value;
	}

	print("RESULT %\n", lowest);
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
