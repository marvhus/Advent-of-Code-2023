/* =========================================================================
 * This is my solutions for day 9 of Advent of Code 2024
 * Copyright (C) 2024  marvhus
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

part_1 :: (path: string) {
    contents, success := read_entire_file(path);
    assert(success);

    blocks := parse(contents);
    compress_blocks(blocks);
    result := calculate_checksum(blocks);

    print("Result : %\n", result);
}

part_2 :: (path: string) {
    contents, success := read_entire_file(path);
    assert(success);

    blocks := parse(contents);
    compress_chunks(blocks);
    result := calculate_checksum(blocks);

    print("Result : %\n", result);
}

Block :: struct {
    Kind :: enum {
        FILLED;
        EMPTY;
    };

    id: u64;
    kind: Kind;
}
BLOCK_ID_INVALID : type_of(Block.id) : 0xFFFFFFFFFFFFFFFF;

calculate_checksum :: (blocks: []Block) -> u64 {
    sum: u64;
    for block, index: blocks {
        if block.kind == .EMPTY continue;
        sum += block.id * xx index;
    }
    return sum;
}

compress_chunks :: (blocks: []Block) {
    find_first :: (blocks: []Block, size: u8, max_index: int) -> (index: int) {
        for block, index: blocks {
            if block.kind == .FILLED continue;

            found_size: u8;
            for index..blocks.count - 1 {
                if it >= max_index break;
                if blocks[it].kind == .FILLED break;
                found_size += 1;
            }

            if found_size < size continue;

            return index;
        }
        return -1;
    }
    measure_length_backward :: (blocks: []Block, end: int) -> (size: u8) {
        id := blocks[end].id;
        size: u8;
        index := end;
        while index > 0 {
            block := blocks[index];
            if block.kind != .FILLED break;
            if block.id != id break;
            size += 1;
            index -= 1;
        }
        return size;
    }

    end := blocks.count - 1;

    while end > 0 {
        block := blocks[end];

        if block.kind == .EMPTY {
            end -= 1;
            continue;
        }

        required_size := measure_length_backward(blocks, end);
        index := find_first(blocks, required_size, end);
        end -= required_size - 1; // Move cursor to start of block.

        if index < 0 {
            end -= 1;
            continue;
        }

        for 0..required_size-1 {
            block_start: *Block = *blocks[index + it];
            block_end: *Block = *blocks[end + it];

            block_start.id = block_end.id;
            block_start.kind = .FILLED;

            block_end.id = BLOCK_ID_INVALID;
            block_end.kind = .EMPTY;
        }

        end -= 1;
    }
}

compress_blocks :: (blocks: []Block) {
    start := 0;
    end := blocks.count - 1;

    while start < end {
        if blocks[end].kind == .EMPTY {
            end -= 1;
            continue;
        }
        if blocks[start].kind == .FILLED {
            start += 1;
            continue;
        }

        block_start: *Block = *blocks[start];
        block_end: *Block = *blocks[end];

        block_start.id = block_end.id;
        block_start.kind = .FILLED;

        block_end.id = BLOCK_ID_INVALID;
        block_end.kind = .EMPTY;
    }
}

print_blocks :: (blocks: []Block) {
    for block: blocks {
        if block.kind == {
            case .FILLED; print("%", block.id);
            case .EMPTY;  print(".");
        }
    }
    print("\n");
}

parse :: (text: string) -> [..]Block {
    blocks: [..]Block;
    // NOTE(mvh): 5 should be around the average segment size, so this should get us close to around the amount of space needed.
    array_reserve(*blocks, text.count * 5);

    is_filled := true;
    id: u64;
    for char: text {
        if char < #char "0" || #char "9" < char continue;

        size := char - #char "0";
        if size < 0 continue;

        if size == 0 {
            is_filled = !is_filled;
            continue;
        }

        if is_filled {
            for 1..size {
                array_add(*blocks, Block.{
                    id = id,
                    kind = .FILLED,
                });
            }
            id += 1;
            is_filled = false;
            continue;
        }

        for 1..size {
            array_add(*blocks, Block.{
                id = BLOCK_ID_INVALID,
                kind = .EMPTY,
            });
        }
        is_filled = true;
    }

    return blocks;
}

#import "File";
#import "String";
#import "Basic";
#import "AoC_Utils";
