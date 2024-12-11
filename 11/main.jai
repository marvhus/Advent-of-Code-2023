/* =========================================================================
 * This is my day 11 solution for Advent of Code 2024.
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
    run("11/test.txt", part_1);
    run("11/input.txt", part_1);

    //print("=== Part 2 ===\n");
    //run("11/test.txt", part_2);
    //run("11/input.txt", part_2);
}

part_1 :: (path: string) {
    contents, success := read_entire_file(path);
    assert(success);

    root := parse(contents,, temp);
    for 0..24 { step(root,, temp); }

    count: int;
    current := root;
    while current != null {
        count += 1;
        current = current.right;
    }

    print("Result : %\n", count);

    reset_temporary_storage();
}

part_2 :: (path: string) {
    contents, success := read_entire_file(path);
    assert(success);

    // @TODO(martin): Implement Part 2.
}

print_nodes :: (root: *Node) {
    current := root;
    print("Nodes: ");
    while current != null {
        print("% ", current.value);
        current = current.right;
    }
    print("\n");
}

Node :: struct {
    left, right: *Node;
    value: u64;
}

create_node :: (value: u64, left: *Node = null, right: *Node = null) -> *Node {
    node := New(Node);
    assert(node != null);

    node.value = value;
    node.left = left;
    node.right = right;

    return node;
}

parse :: (text: string) -> root: *Node {
    root, current: *Node;

    for stone: split(text, " ") {
        number := string_to_int(stone, 10, u64);

        if root == null {
            root = create_node(number);
            current = root;
            continue;
        }

        node := create_node(number, current);
        current.right = node;
        current = node;
    }

    return root;
}

step :: (root: *Node) {
    current := root;
    while current != null {
        defer current = current.right;

        if current.value == 0 {
            current.value = 1;
            continue;
        }

        digits := count_digits(current.value);
        if digits % 2 == 0 {
            // NOTE(mvh): This is a terrible way of doing this... but it works.
            number_string := tprint("%", current.value);

            left_half := string.{data = number_string.data, count = number_string.count / 2};
            right_half := string.{data = number_string.data + left_half.count, count = number_string.count - left_half.count};

            left_value := string_to_int(left_half, 10, u64);
            right_value := string_to_int(right_half, 10, u64);

            right_node := create_node(right_value, left = current, right = current.right);
            current.right = right_node;

            current.value = left_value;

            current = right_node;
            continue;
        }

        current.value *= 2024;
    }
}

count_digits :: (number: u64) -> count: int {
    count: int = 1;
    n := number;
    while n >= 10 {
        count += 1;
        n /= 10;
    }
    return count;
} 

#import "File";
#import "String";
#import "Basic";
#import "AoC_Utils";
