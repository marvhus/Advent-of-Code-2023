#import,dir "..";

main :: () {
    text := "Hello, World!\r\nHello\nSailor.";
    for split_newlines(text) {
        print("LINE %: '%'\n", it_index, it);
    }
}

#import "Basic";
