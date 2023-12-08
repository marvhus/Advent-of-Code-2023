split_newlines :: (text: string) -> lines: []string {
    lines: [..]string;
    for win_line: split(text, "\r\n") {
        for nix_line: split(win_line, "\n") {
            array_add(*lines, nix_line);
        }
    }
    return lines;
}

#scope_file

#import "String";
#import "Basic";
