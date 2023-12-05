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
	// part_1("05/test.txt");
	part_1("05/input.txt");
}

DEBUG :: false;

Mapping :: struct {
	dest, src, len : u64;
}
DEST :: 0;
SRC  :: 1;
LEN  :: 2;

split_to_numbers :: (line : string, sep : string = " ", $T := u64) -> []T {
	res : [..]T;
	for str_num : split(line, sep) {
		if str_num.count == 0 continue;
		num, has_num := string_to_int(str_num, 10, T);
		assert(has_num);
		array_add(*res, num);
	}
	return res;
}

////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////

part_1 :: (path : string) {
	contents, success := read_entire_file(path);
	assert(success);

	seeds : []u64 = ---;
	map : [..]Mapping;
	has_seeds := false;
	reading_map := false;
	
	for line : split_newlines(contents) {
		if !has_seeds && begins_with(line, "seeds:") {
			success, _, numbers := split_from_left(line, ": ");
			seeds = split_to_numbers(numbers);
			has_seeds = true;
			continue;
		}
		assert(has_seeds); // we need seeds

		if line.count == 0 {
			if reading_map {
#if DEBUG {
	print("map :: [\n");
	for mapping : map print("\tMapping.{dest = %, src = %, len = %}\n",
							mapping.dest, mapping.src, mapping.len);
	print("]\n");
}
				
				for *seed : seeds {
#if DEBUG {
	print("% -> ", seed.*);
	changed := false;
}
					for mapping : map {
						if seed.* >= mapping.src && seed.* <= mapping.src + mapping.len - 1 {
							seed.* += mapping.dest - mapping.src;
#if DEBUG {
	print("% -- % Changed\n", seed.*, mapping);
	changed = true;
}
							break;
						}
					}
#if DEBUG {
	if !changed then print("%\n", seed.*);
}
				}
#if DEBUG {
	print("\n");
}
				reading_map = false;
				array_reset(*map);
			}
			continue;
		}
		
		if ends_with(line, "map:") {
			reading_map = true;
			continue;
		}

		nums := split_to_numbers(line);
		assert(nums.count == 3);
		array_add(*map, .{
			dest = nums[DEST],
			src  = nums[SRC],
			len  = nums[LEN]
		});
	}

	lowest : u64 = 1 << 63;
	for seed : seeds {
		if seed < lowest then lowest = seed;
	}

	print("RESULT %\n", lowest);
}

////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////

part_2 :: (path: string) {
	contents, success := read_entire_file(path);
	assert(success);
	seeds : []u64 = ---;
	map : [..]Mapping;
	has_seeds := false;
	reading_map := false;
	
	for line : split_newlines(contents) {
		if !has_seeds && begins_with(line, "seeds:") {
			success, _, numbers := split_from_left(line, ": ");
			seeds = split_to_numbers(numbers);
			has_seeds = true;
			continue;
		}
		assert(has_seeds); // we need seeds

		if line.count == 0 {
			if reading_map {
#if DEBUG {
	print("map :: [\n");
	for mapping : map print("\tMapping.{dest = %, src = %, len = %}\n",
							mapping.dest, mapping.src, mapping.len);
	print("]\n");
}
				
				for *seed : seeds {
#if DEBUG {
	print("% -> ", seed.*);
	changed := false;
}
					for mapping : map {
						if seed.* >= mapping.src && seed.* <= mapping.src + mapping.len - 1 {
							seed.* += mapping.dest - mapping.src;
#if DEBUG {
	print("% -- % Changed\n", seed.*, mapping);
	changed = true;
}
							break;
						}
					}
#if DEBUG {
	if !changed then print("%\n", seed.*);
}
				}
#if DEBUG {
	print("\n");
}
				reading_map = false;
				array_reset(*map);
			}
			continue;
		}
		
		if ends_with(line, "map:") {
			reading_map = true;
			continue;
		}

		nums := split_to_numbers(line);
		assert(nums.count == 3);
		array_add(*map, .{
			dest = nums[DEST],
			src  = nums[SRC],
			len  = nums[LEN]
		});
	}

	lowest : u64 = 1 << 63;
	for seed : seeds {
		if seed < lowest then lowest = seed;
	}

	print("RESULT %\n", lowest);
}

#import "File";
#import "String";
#import "Basic";
#import "AoC_Utils";
