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

}

part_1 :: (path: string) {
	contents, success := read_entire_file(path);
	assert(success);

	// @TODO(martin): Implement Day 1.
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
