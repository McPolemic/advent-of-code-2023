def score_card_star_1(line)
  cards = line.split(": ").last
  winning_numbers, my_numbers = cards
    .split(" | ")
    .map{ |side| side.split(" ") }

  winning_amount = my_numbers.intersection(winning_numbers).length

  return 0 if winning_amount == 0
  2 ** (winning_amount - 1)
end

if __FILE__ == $0
  file_path = File.join(File.dirname(__FILE__), 'day4.txt')
  input = File.readlines(file_path, chomp: true)

  star_1 = input.map { |card| score_card_star_1(card) }.sum
  star_2 = nil

  puts "Star 1: #{star_1}"
  puts "Star 2: #{star_2}"
end
