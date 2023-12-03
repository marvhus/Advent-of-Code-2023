main :: () {
//    part_1("03/test.txt");
//    part_1("03/input.txt");
//    part_1("03/reddit_test.txt");
    part_1("03/reddit_test2.txt");
}

Position :: struct {
    row, col: s16;
}
Number :: struct {
    row, col: s16;
    num: u64;
    len: s16;
    found_syms: u16;
}

inside_range :: (num: Number, pos: s16) -> bool {
    return pos >= num.col && pos <= num.col + num.len;
}

part_1 :: (path: string) {
    content, success := read_entire_file(path);
    assert(success);

    nums: [..]Number;
    syms: [..]Position;

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
                array_add(*nums, .{xx it_index, col, num, xx num_start.count, 0});

                col += xx num_start.count;
                continue;
            } else
            if line[0] != #char "." && line[0] != #char "\r" {
                array_add(*syms, .{xx it_index, col});
            }

            line.data += 1;
            line.count -= 1;
            col += 1;
        }
    }

    // probably verry slow, but it should work.
    total: u64;
    for sym: syms {
        for *num: nums {
            if num.found_syms > 0 continue;

            if num.row == sym.row - 1
            || num.row == sym.row
            || num.row == sym.row + 1 {
                if inside_range(num, sym.col - 1)
                || inside_range(num, sym.col)
                || inside_range(num, sym.col + 1) {
                    total += num.num;
                    num.found_syms += 1;
                }
            }
        }
    }
    for nums if it.found_syms == 0 then print("%\n", it.num);
    print("TOTAL %\n", total);
}

#import "Basic";
#import "File";
#import "String";
