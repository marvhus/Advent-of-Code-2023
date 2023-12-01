main :: () {
//    part_1("01/test.txt");
//    part_1("01/input.txt");
//    part_2("01/test_p2.txt");
    part_2("01/input.txt");
}

part_2 :: (input: string) {
    content, success := read_entire_file(input);
    assert(success);

    // checks if it's a letter representation of a number
    // e.g. one, two, threee, ...
    // if it's none it's 0
    // zero is not valid in this case, so we can do this.
    // if it was you could use a bool, or use a s8 and do -1
    check_for_number_word :: (str: string) -> u8 {
        // there is more optimal ways of doing this, but it works.
        words := string.[ // I am too lazy to make all the if statements
            "one", "two", "three",
            "four", "five", "six",
            "seven", "eight", "nine"
        ];
        for word: words {
            // + 1 because it's 1-9 not 0-9
            if begins_with(str, word) return cast(u8) it_index + 1;
        }
        return 0;
    }

    total : u64;
    for split(content, "\n") { // might work on Windows (CRLF), but idk
        if it.count == 0 continue; // ignore blank lines
        line := it;
        first: u8;
        last: u8;
        while line.count > 0 { // we doing some fancy shit here
            chr := line[0];
            // is normal digit
            if chr >= #char "0" && chr <= #char "9" {
                num := chr - #char "0";
                if first == 0 then first = num;
                last = num;
            } else {
                num := check_for_number_word(line);
                if num != 0 {
                    if first == 0 then first = num;
                    last = num;
                }
            }

            line.count -= 1;
            line.data += 1;
        }
        first *= 10;
        total += first + last;
    }
    print("%\n", total);
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
