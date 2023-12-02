# Simple Result monad
Success = Struct.new(:id) do
  def success? = true
  def failure? = false
end

Failure = Struct.new(:id, :errors) do
  def success? = false
  def failure? = true
end

class GameParser
  attr_reader :max_red, :max_green, :max_blue

  def initialize(max_red:, max_green:, max_blue:)
    @max_red = max_red
    @max_green = max_green
    @max_blue = max_blue
  end

  # Divides up a hint string into something #valid? can read
  # Example hint:
  # 'Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green'
  def parse_hint_string(hint)
    id, text_hints = hint.match(/Game (\d+): (.+)/).captures

    hints = text_hints.split("; ").map do |text_hint|
      text_hint.split(", ").map do |text_hint_subset|
        num, color = text_hint_subset.split(" ")
        [color.to_sym, num.to_i]
      end.to_h
    end

    [id.to_i, hints]
  end

  def hint_string_valid?(hint)
    id, hints = parse_hint_string(hint)

    valid?(*parse_hint_string(hint))
  end

  def valid?(id, hints)
    max_values = {red: max_red, green: max_green, blue: max_blue}
    errors = []

    # for each hint, we compare our max values with the hint value
    # if any exceed the max value for that color, we mark it invalid
    hints.all? do |hint|
      max_values.each do |color, max_value|
        if hint.key?(color) && hint[color] > max_value
          errors << "#{hint[color]} #{color} is greater than #{max_value}"
        end
      end
    end

    if errors.empty?
      Success.new(id)
    else
      Failure.new(id, errors)
    end
  end
end

if __FILE__ == $0
  file_path = File.join(File.dirname(__FILE__), 'day2.txt')
  input = File.readlines(file_path, chomp: true)

  game = GameParser.new(max_red: 12, max_green: 13, max_blue: 14) 

  star_1 = input
    .map{ |hint| game.hint_string_valid?(hint) }
    .select(&:success?)
    .map(&:id)
    .sum
  star_2 = nil

  puts "Star 1: #{star_1}"
  puts "Star 2: #{star_2}"
end
