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
    print("Running with '%'\n", path);
    func(path);
}

main :: () {
    print("=== Part 1 ===\n");
    run("07/test.txt", part_1);
    run("07/input.txt", part_1);

    //print("=== Part 2 ===\n");
    //run("07/test.txt", part_2);
    //run("07/input.txt", part_2);
}

part_1 :: (path: string) {
    contents, success := read_entire_file(path);
    assert(success);

    equations := parse(contents);
    result: u64;

    for equation: equations {
        print("Equation %\n", it_index);
        if can_be_evaluated(equation) result += equation.result;
    }

    print("Result : %\n", result);

    // Cleanup.
    for equation: equations { array_free(equation.factors); }
    array_free(equations);
}

part_2 :: (path: string) {
    contents, success := read_entire_file(path);
    assert(success);

    // @TODO(martin): Implement Part 2.
}

Equation :: struct {
    result: u64;
    factors: []u64;
}
Operator :: enum {
    ADD;
    MUL;
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

can_be_evaluated :: (equation: Equation) -> bool {
    operators := NewArray(equation.factors.count - 1, Operator);
    defer array_free(operators);

    combinations: u64 = cast(u64)1 << cast(u64)(equation.factors.count - 1);
    //print("Combinations %\n", combinations);

    for combination: 0 .. combinations - 1 {
        print("Attempting %...\n", combination); // If I remove this, this becomes an infinite loop...
        // Fill out operators.
        for *operation: operators {
            operation.* = ifx combination & 1 then .ADD else .MUL;
            combination >>= 1;
        }
        //print("Thing\n");

        result := evaluate(equation, operators);
        if result == equation.result return true;
    }

    return false;
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
        }
    }

    return result;
}

#import "File";
#import "String";
#import "Basic";
#import "AoC_Utils";
