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
    return nil if y > data.length
    return nil if x > data.first.length

    data[y][x]
  end

  def numbers_at(coords)
    coords.map do |(x, y)|
      at(x, y).to_i
    end
  end

  def surrounding_coords(start, finish, &block)
    x, y = start
    (-1..1).flat_map do |y_offset|
      (-1..1).map do |x_offset|
        next if x_offset == 0 && y_offset == 0
        [x + x_offset, y + y_offset]
      end
    end.compact
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

def parse_input(grid)
  symbols = find_symbols(grid)
  #numbers = find_numbers(symbols, grid)
end

if __FILE__ == $0
  file_path = File.join(File.dirname(__FILE__), 'day3.txt')
  input = File.readlines(file_path, chomp: true).map(&:chars)

  star_1 = Grid.new(input)
  star_2 = nil

  puts "Star 1: #{star_1}"
  puts "Star 2: #{star_2}"
end
