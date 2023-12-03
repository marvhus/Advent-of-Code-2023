main :: () {
//    part_1("03/test.txt");
//    part_1("03/input.txt");
//    part_1("03/my_test.txt");
//    part_1("03/reddit_test.txt");
//    part_1("03/reddit_test2.txt");
//    part_2("03/test.txt");
    part_2("03/input.txt");
}

LOG_NOT_ALREADY_FOUND :: false;

Position :: struct {
    row, col: s16;
}
Number :: struct {
    row, col: s16;
    num: u64;
    len: s16;
    already_found: bool;
}

inside_range :: (num: Number, pos: s16) -> bool {
    return pos >= num.col && pos <= num.col + num.len;
}

is_sym :: (chr: u8) -> bool {
    return !is_digit(chr) && chr != #char "." && chr != #char "\r";
}

part_1 :: (path: string) {
    content, success := read_entire_file(path);
    assert(success);

    nums: [..]Number;

    // parse out the numbers

    lines := split(content, "\n"); // maybe handle Windows newlines (CRLF)
    for lines {
        if it.count == 0 continue;
        line := it;
        col: s16;
        while line.count > 0 {
            if is_digit(line[0]) {
                num_start := line;
                num_start.count = 0;
                while line.count > 0 && is_digit(line[0]) {
                    num_start.count += 1;
                    line.data += 1;
                    line.count -= 1;
                }
                num, found_num, remaining := string_to_int(num_start, 10, u64);
                assert(found_num);
                array_add(*nums, .{xx it_index, col, num, xx num_start.count, false});

                col += xx num_start.count;
                continue;
            } else

            line.data += 1;
            line.count -= 1;
            col += 1;
        }
    }

    // check around the numbers

    total: u64;
    for *num: nums {
        for row: num.row - 1 .. num.row + 1 {
            if num.already_found break;
            if row < 0 || row >= lines.count continue;
            line := lines[row];
            for col: num.col - 1 .. num.col + num.len {
                if col < 0 || col >= line.count continue;
                chr := line[col];
                if is_sym(chr) {
                    total += num.num;
                    num.already_found = true;
                    break;
                }
            }
        }
    }

    // debug output
#if LOG_NOT_ALREADY_FOUND {
    print("Not next to symbol: ");
    for nums if !it.already_found then print("% ", it.num);
    print("\n");
}

    // print result

    print("TOTAL %\n", total);
}

find_num :: (line: string, col: s16) -> u64 {
    start := col;
    while start >= 0 && is_digit(line[start]) {
        start -= 1;
    }
    if start < 0 then start = 0;
    if !is_digit(line[start]) then start += 1;

    offset_line := line;
    offset_line.data += start;
    offset_line.count -= start;

    num, found_num := string_to_int(offset_line, 10, u64);
    assert(found_num);

    return num;
}

part_2 :: (path: string) {
    content, success := read_entire_file(path);
    assert(success);

    total: u64;

    lines := split(content, "\n"); // maybe handle Windows newlines (CRLF)
    for line, row: lines {
        if line.count == 0 continue;
        for col: 0..line.count-1 {
            nums: [2]u64;
            count: u8;
            chr := line[col];
            if chr != #char "*" continue;

            // check left
            if col > 0 && is_digit(line[col - 1]) {
                nums[count] = find_num(line, cast(s16) col - 1);
                count += 1;
            }
            // check right
            if col < line.count - 1 && is_digit(line[col + 1]) {
                nums[count] = find_num(line, cast(s16) col + 1);
                count += 1;
            }
            // check above
            if row > 0 {
                line_above := lines[row - 1];
                // check directly above
                if is_digit(line_above[col]) { // combined
                    if count >= 2 continue;
                    nums[count] = find_num(line_above, cast(s16) col);
                    count += 1;
                } else { // split
                    // above and to the left
                    if col > 0 && is_digit(line_above[col - 1]) {
                        if count >= 2 continue;
                        nums[count] = find_num(line_above, cast(s16) col - 1);
                        count += 1;
                    }
                    // above and to the right
                    if col < line_above.count - 1 && is_digit(line_above[col + 1]) {
                        if count >= 2 continue;
                        nums[count] = find_num(line_above, cast(s16) col + 1);
                        count += 1;
                    }
                }
            }
            // it can't be above 2
            if count > 2 continue;
            // check below
            if row < lines.count - 1 {
                line_below := lines[row + 1];
                // check directly below
                if is_digit(line_below[col]) { // combined
                    if count >= 2 continue;
                    nums[count] = find_num(line_below, cast(s16) col);
                    count += 1;
                } else { // split
                    // below and to the left
                    if col > 0 && is_digit(line_below[col - 1]) {
                        if count >= 2 continue;
                        nums[count] = find_num(line_below, cast(s16) col - 1);
                        count += 1;
                    }
                    // above and to the right
                    if col < line_below.count - 1 && is_digit(line_below[col + 1]) {
                        if count >= 2 continue;
                        nums[count] = find_num(line_below, cast(s16) col + 1);
                        count += 1;
                    }
                }
            }

            if count != 2 continue;

            total += nums[0] * nums[1];

            //print("% % %\n", row, col, nums);
        }
    }

    // print result

    print("TOTAL %\n", total);
}

#import "Basic";
#import "File";
#import "String";
