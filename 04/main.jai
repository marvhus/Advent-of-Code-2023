main :: () {
//	part_1("04/test.txt");
//	part_1("04/input.txt");
//	part_2("04/test.txt");
	part_2("04/input.txt");
}

part_2 :: (path: string) {
	contents, success := read_entire_file(path);
	assert(success);

	total : u64;

	split_the_number_list :: (number_list: string) -> [..]u8 {
		numbers : [..]u8;
		for str_num : split(number_list, " ") {
			if str_num.count == 0 continue; // parsing non existant numbers would be stupid.
			num, has_number := string_to_int(str_num, 10, u8); // probably won't have masive numbers.
			assert(has_number); // check your input.
			
			array_add(*numbers, num);
		}
		return numbers;
	}

	cards : [255]u64; // this should be more than enough for now.
	// ^ should be zero initialized
	
	card_count := 0;
	for line, card_id : split_newlines(contents) {
		if line.count == 0 continue; // ignore blank lines

		// so we can keep track of how many we have
		card_count += 1;

		found_numbers, _, numbers := split_from_left(line, ": ");
		assert(found_numbers);

		found_bar, str_winning_numbers, str_your_numbers := split_from_left(numbers, " | ");
		assert(found_bar);

		winning_numbers := split_the_number_list(str_winning_numbers);
		your_numbers := split_the_number_list(str_your_numbers);
		
		winning_count : u8;
		// there is probably a better way to do this, but it works for now.
		for your_num : your_numbers {
			for winning_number : winning_numbers {
				if your_num == winning_number {
					winning_count += 1;
				}
			}
		}
		if winning_count > 0 for 1..winning_count {
			tmp_card_id := card_id + it;
			if tmp_card_id >= cards.count break; // no overflow here.
			cards[tmp_card_id] += cards[card_id] + 1; // the copies win too.
		}
	}

	for card: cards {
		if it_index >= card_count break; // we can't win copies of cards we don't have.
		print("card % value: %\n", it_index + 1, card);
		total += xx card;
	}
	
	print("TOTAL: %\n", total);
}

part_1 :: (path: string) {
	contents, success := read_entire_file(path);
	assert(success);

	total : u64;

	split_the_number_list :: (number_list: string) -> [..]u8 {
		numbers : [..]u8;
		for str_num : split(number_list, " ") {
			if str_num.count == 0 continue; // parsing non existant numbers would be stupid.
			num, has_number := string_to_int(str_num, 10, u8); // probably won't have masive numbers.
			assert(has_number); // check your input.
			
			array_add(*numbers, num);
		}
		return numbers;
	}
	
	for line : split_newlines(contents) {
		if line.count == 0 continue; // ignore blank lines

		found_numbers, _, numbers := split_from_left(line, ": ");
		assert(found_numbers);

		found_bar, str_winning_numbers, str_your_numbers := split_from_left(numbers, " | ");
		assert(found_bar);

		winning_numbers := split_the_number_list(str_winning_numbers);
		your_numbers := split_the_number_list(str_your_numbers);
		
		winning_count : u8;
		// there is probably a better way to do this, but it works for now.
		for your_num : your_numbers {
			for winning_number : winning_numbers {
				if your_num == winning_number then winning_count += 1;
			}
		}

		if winning_count > 0 {
			score : u64 = 1;
			score <<= (winning_count-1);
			total += score;
		}
	}
	print("%\n", total);
}

strip_spaces :: (str: string) -> string {
	tmp_str := str;
	while tmp_str.count > 0 && is_space(str[0]) {
		tmp_str.data += 1;
		tmp_str.count -= 1;
	}
	return str;
}

#import "File";
#import "String";
#import "Basic";
#import "AoC_Utils";
