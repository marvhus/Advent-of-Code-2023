main :: () {
//    part_1("02/test.txt", 12, 13, 14);
//    part_1("02/input.txt", 12, 13, 14);
//    part_2("02/test.txt");
    part_2("02/input.txt");
}

Colors :: struct {
    TYPE :: u16;
    red, green, blue : Colors.TYPE;
}

part_2 :: (path : string) {
    content, success := read_entire_file(path);
    assert(success);

    total : u64;
    for line : split(content, "\n") {
        if line.count <= 0 continue; // ignore blank lines

        found, game, rest := split_from_left(line, ": ");
        assert(found);

        found_2, _, id_str := split_from_left(game, " ");
        assert(found_2);

        id, has_number := string_to_int(id_str, 10, u64);
        assert(has_number);

        colors : Colors;
        for set : split(rest, "; ") {
            for cubes : split(set, ", ") {
                found, count, color := split_from_left(cubes, " ");
                assert(found);

                num, has_number := string_to_int(count, 10, Colors.TYPE);
                assert(has_number);

                if color == {
                    case "red"; colors.red = max(num, colors.red);
                    case "green"; colors.green = max(num, colors.green);
                    case "blue"; colors.blue = max(num, colors.blue);
                }
            }
        }
        power := colors.red * colors.green * colors.blue;
        total += power;
    }

    print("%\n", total);
}

part_1 :: (path : string, max_red : Colors.TYPE, max_green : Colors.TYPE, max_blue : Colors.TYPE) {
    content, success := read_entire_file(path);
    assert(success);

    total : u64;
    for line : split(content, "\n") {
        if line.count <= 0 continue; // ignore blank lines

        found, game, rest := split_from_left(line, ": ");
        assert(found);

        found_2, _, id_str := split_from_left(game, " ");
        assert(found_2);

        id, has_number := string_to_int(id_str, 10, u64);
        assert(has_number);

        colors : Colors;
        for set : split(rest, "; ") {
            for cubes : split(set, ", ") {
                found, count, color := split_from_left(cubes, " ");
                assert(found);

                num, has_number := string_to_int(count, 10, Colors.TYPE);
                assert(has_number);

                if color == {
                    case "red"; colors.red = max(num, colors.red);
                    case "green"; colors.green = max(num, colors.green);
                    case "blue"; colors.blue = max(num, colors.blue);
                }
            }
        }
        if colors.red   <= max_red
        && colors.green <= max_green
        && colors.blue  <= max_blue {
            total += xx id;
        }
    }

    print("%\n", total);
}

#import "Basic";
#import "File";
#import "String";
