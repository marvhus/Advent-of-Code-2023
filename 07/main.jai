/* =========================================================================
 * This is template.jai
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
    //print("Running with '%'\n", path);
    func(path);
}

main :: () {
    print("=== Part 1 ===\n");
    run("07/test.txt", part_1);
    run("07/input.txt", part_1);

    print("=== Part 2 ===\n");
    run("07/test.txt", part_2);
    run("07/input.txt", part_2);
}

part_1 :: (path: string) {
    contents, success := read_entire_file(path);
    assert(success);

    equations := parse(contents);
    result: u64;

    for equation: equations {
        if can_be_evaluated(equation) {
            result += equation.result;
        }
    }

    print("Result : %\n", result);

    // Cleanup.
    for equation: equations { array_free(equation.factors); }
    array_free(equations);
}

part_2 :: (path: string) {
    contents, success := read_entire_file(path);
    assert(success);

    equations := parse(contents);
    result: u64;

    for equation: equations {
        if can_be_evaluated(equation, is_part_2 = true) {
            result += equation.result;
        }
    }

    print("Result : %\n", result);

    // Cleanup.
    for equation: equations { array_free(equation.factors); }
    array_free(equations);
}

Equation :: struct {
    result: u64;
    factors: []u64;
}
Operator :: enum u8 {
    ADD;
    MUL;
    APPEND;
}

parse :: (text: string) -> []Equation {
    lines := split_newlines(text);
    lines.count -= 1;

    equations := NewArray(lines.count, Equation);

    for *equation: equations {
        line := lines[it_index];

        found, result_section, factor_section := split_from_left(line, ": ");
        assert(found);

        { // Result
            result, success := string_to_int(result_section, 10, u64);
            assert(success);

            equation.result = result;
        }

        { // Factors
            factor_strings := split(factor_section, " ");
            factors := NewArray(factor_strings.count, u64);

            for *factor: factors {
                factor_result, success := string_to_int(factor_strings[it_index], 10, u64);
                assert(success);

                factor.* = factor_result;
            }

            equation.factors = factors;
        }
    }

    return equations;
}

can_be_evaluated :: (equation: Equation, is_part_2 := false) -> bool {
    operators := NewArray(equation.factors.count - 1, Operator);
    defer array_free(operators);

    last := false;
    while true {
        result := evaluate(equation, operators);
        if result == equation.result return true;

        if last break;
        if iterate(operators, is_part_2) last = true;
    }

    return false;
}

iterate :: (operators: []Operator, is_part_2 := false) -> overflow: bool {
    wrapped := false;
    highest := 0;

    for *operation: operators {
        highest = it_index;
        if #complete operation.* == {
            case .ADD;
                operation.* = .MUL;
                wrapped = false;
            case .MUL;
                if is_part_2 {
                    operation.* = .APPEND;
                    wrapped = false;
                } else {
                    operation.* = .ADD;
                    wrapped = true;
                }
            case .APPEND;
                operation.* = .ADD;
                wrapped = true;
        }

        if ! wrapped break;
    }

    return highest >= operators.count - 1 && wrapped;
}

evaluate :: (equation: Equation, operators: []Operator) -> u64 {
    result: u64;
    first := true;

    for operation: operators {
        left, right: u64;
        if first {
            left  = equation.factors[0];
            right = equation.factors[1];
            first = false;
        } else {
            left  = result;
            right = equation.factors[it_index + 1];
        }

        if #complete operation == {
            case .ADD; result = left + right;
            case .MUL; result = left * right;
            case .APPEND;
                text := sprint("%1%2", left, right);
                result=, success := string_to_int(text, 10, u64);
                free(text);
        }
    }

    return result;
}

#import "File";
#import "String";
#import "Basic";
#import "AoC_Utils";
