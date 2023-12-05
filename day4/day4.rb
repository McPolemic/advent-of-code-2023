def winning_amounts(card_inputs)
  cards = card_inputs.map do |line|
    cards = line.split(": ").last
    winning_numbers, my_numbers = cards
      .split(" | ")
      .map{ |side| side.split(" ") }

    winning_amount = my_numbers.intersection(winning_numbers).length
  end
end

def star_1_score(card_inputs)
  amounts = winning_amounts(card_inputs)

  amounts.map do |amount|
    next 0 if amount == 0

    2 ** (amount - 1)
  end.sum
end

def star_2_score(card_inputs)
  amounts = winning_amounts(card_inputs)
  additional = Hash.new(0)

  amounts.each_with_index.reduce(0) do |total, (amount, index)|
    # You have the one card already, plus any bonus cards from
    # previous rounds
    copies = 1 + additional[index]
    copies.times.each do
      (index+1..index+amount).each { |i| additional[i] += 1 }
    end

    total += copies
  end
end

if __FILE__ == $0
  file_path = File.join(File.dirname(__FILE__), 'day4.txt')
  input = File.readlines(file_path, chomp: true)

  star_1 = star_1_score(input)
  star_2 = star_2_score(input)

  puts "Star 1: #{star_1}"
  puts "Star 2: #{star_2}"
end
