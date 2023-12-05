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
	//part_1("05/test.txt");
	//part_1("05/input.txt");
	//part_2("05/test.txt");
	part_2("05/input.txt");
}

DEBUG :: false;

Mapping :: struct {
	dest, src, len : u64;
}
Map :: []Mapping;
Seed_Range :: struct {
	src, len : u64;
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
				for *seed : seeds {
					for mapping : map {
						if seed.* >= mapping.src && seed.* <= mapping.src + mapping.len - 1 {
							seed.* += mapping.dest - mapping.src;
							break;
						}
					}
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
	seed_ranges : [..]Seed_Range;
	maps : [..]Map;
	
	{
		contents, success := read_entire_file(path);
		assert(success);
		map : [..]Mapping;
		has_seeds := false;
		reading_map := false;
		
		print("Parsing\n");
		for line : split_newlines(contents) {
			if !has_seeds && begins_with(line, "seeds:") {
				success, _, numbers := split_from_left(line, ": ");
				tmp_seed_ranges := split_to_numbers(numbers);
				assert(seed_ranges.count % 2 == 0); // has to be divisable by 2
				i := 0;
				while i < tmp_seed_ranges.count {
					src := tmp_seed_ranges[i];
					len := tmp_seed_ranges[i+1];
					array_add(*seed_ranges, Seed_Range.{src, len});
					i += 2;
				}
				has_seeds = true;
				continue;
			}
			assert(has_seeds); // we need seeds
			
			if line.count == 0 {
				if reading_map {
					array_add(*maps, array_copy(map));
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
		print("Parsed\n");
	}

	print("Seed Ranges: %\n", seed_ranges.count);
	print("Maps: %\n", maps.count);
	
	lowest : u64 = 1 << 63;
	// ......
	for seed_range : seed_ranges {
		print("Seed Range %, % : time: %\n", it_index, seed_range, get_time());
        count : u64 = 0;
        first := true;
		for seed : seed_range.src .. seed_range.src + seed_range.len - 1 {
            if !first && count % 10_000_000 == 0 {
                print("10M Seeds. seed: %, time: %\n", seed, get_time());
            }
            first = false;
            count += 1;
			value := seed;
			for map : maps {
				for mapping : map {
					if value >= mapping.src && value < mapping.src + mapping.len {
						value += mapping.dest - mapping.src;
					}
				}
			}
			if value < lowest then lowest = value;
		}
	}
	print("\n-------------------------\nLOWEST %\n", lowest);
	
}

#import "File";
#import "String";
#import "Basic";
#import "AoC_Utils";
