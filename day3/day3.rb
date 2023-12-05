class CoordinateMatch
  attr_reader :value, :start, :finish

  def initialize(value, start:, finish:)
    @value = value
    @start = start
    @finish = finish
  end

  def coordinates
    [start, finish]
  end
end

class Grid
  include Enumerable

  attr_reader :data

  def initialize(data)
    @data = data
  end

  def at(x, y)
    # Out of bounds checks
    return nil if x < 0 || y < 0
    return nil if y > data.length - 1
    return nil if x > data.first.length - 1

    data[y][x]
  end

  def surrounding_coords(start, finish, &block)
    start_x, start_y = start
    finish_x, finish_y = finish
    coords = (start_y-1..finish_y+1).flat_map do |y|
               (start_x-1..finish_x+1).map do |x|
                 # Skip if it's within the coordinate rectangle
                 next if x >= start_x &&
                         y >= start_y &&
                         x <= finish_x &&
                         y <= finish_y

                 [x, y]
               end
             end.compact
    if block_given?
      coords.each{ |coord| yield coord }
    else
      coords
    end
  end

  def surrounding_values(start, finish)
    surrounding_coords(start, finish).map do |coord|
      at(*coord)
    end
  rescue
    require 'pry'; binding.pry
  end

  def each_row(&block)
    data.each_with_index do |rows, y|
      yield(rows.join, y)
    end
  end

  def map_row(&block)
    data.map.with_index do |rows, y|
      yield(rows.join, y)
    end
  end

  def each(&block)
    data.each_with_index do |rows, y|
      rows.each_with_index do |chars, x|
        yield(chars, [x, y])
      end
    end
  end
end

def find_symbols(grid)
  grid.map { |char, coord| char == '*' ?  coord : skip }
end

def find_numbers(grid)
  grid.map_row do |row, y|
    row.enum_for(:scan, /\d+/).map do
      match = Regexp.last_match

      CoordinateMatch.new(match.to_s.to_i,
                          start: [match.begin(0), y],
                          finish: [match.end(0)-1, y])
    end
  end.flatten
end

def find_valid_numbers(grid)
  find_numbers(grid).select do |possible_number|
    start, finish = possible_number.coordinates

    # Does it have punctuation around it?
    grid.surrounding_values(start, finish).map do |value|
      value =~ /[^.\d]/
    end.any?
  end.map(&:value)
end

if __FILE__ == $0
  file_path = File.join(File.dirname(__FILE__), 'day3.txt')
  input = File.readlines(file_path, chomp: true).map(&:chars)

  star_1 = find_valid_numbers(Grid.new(input)).sum
  star_2 = nil

  puts "Star 1: #{star_1}"
  puts "Star 2: #{star_2}"
end
