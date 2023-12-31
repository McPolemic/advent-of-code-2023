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
  attr_accessor :red, :green, :blue

  def initialize(red:, green:, blue:)
    @red = red
    @green = green
    @blue = blue
  end

  def self.new_from_hint(hint)
    _, hints = parse_hint_string(hint)

    merged = {red: 0, green: 0, blue: 0}

    # Find the max number for each color
    hints.reduce(merged) do |acc, set|
      set.each do |color, num|
        acc[color] = num if acc[color] < num
      end

      acc
    end

    GameParser.new(**merged)
  end

  def product
    red * green * blue
  end

  # Divides up a hint string into something #valid? can read
  # Example hint:
  # 'Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green'
  def self.parse_hint_string(hint)
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
    results = self.class.parse_hint_string(hint)
    valid?(*results)
  end

  def valid?(id, hints)
    values = {red: red, green: green, blue: blue}
    errors = []

    # for each hint, we compare our max values with the hint value
    # if any exceed the max value for that color, we mark it invalid
    hints.all? do |hint|
      values.each do |color, value|
        if hint.key?(color) && hint[color] > value
          errors << "#{hint[color]} #{color} is greater than #{value}"
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

  game = GameParser.new(red: 12, green: 13, blue: 14)

  star_1 = input
    .map{ |hint| game.hint_string_valid?(hint) }
    .select(&:success?)
    .map(&:id)
    .sum
  star_2 = input
    .map{ |hint| GameParser.new_from_hint(hint).product }
    .sum

  puts "Star 1: #{star_1}"
  puts "Star 2: #{star_2}"
end
