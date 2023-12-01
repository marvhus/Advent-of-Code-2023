main :: () {
//    part_1("01/test.txt");
    part_1("01/input.txt");
}

part_1 :: (input: string) {
    content, success := read_entire_file(input);
    assert(success);

    total : u64;
    for line: split(content, "\n") { // might work on Windows (CRLF), but idk
        if line.count == 0 continue; // ignore blank lines
        first : u8;
        last : u8;
        for 0..line.count-1 {
            chr := line[it];
            if chr >= #char "0" && chr <= #char "9" {
                num := chr - #char "0";
                if first == 0 then first = num;
                last = num;
            }
        }
        first *= 10;
        total += first + last;
    }
    print("%\n", total);
}

#import "Basic";
#import "String";
#import "File";
