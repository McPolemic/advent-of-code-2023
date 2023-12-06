class Range
  # Honestly, this should already exist :/
  def intersects?(other)
    cover?(other) ||
      self.begin.between?(other.begin, other.end) ||
      self.end.between?(other.begin, other.end)
  end

  # Cuts a range into up to three ranges:
  # * before the other range
  # * in-between the other range
  # * after the other range
  def cut(other)
    return [self] unless intersects? other
    return [self] if other.cover?(self)

    if self.cover?(other)
      [self.begin..other.begin-1, other.begin..other.end, other.end+1..self.end]
    elsif self.begin.between?(other.begin, other.end)
      [self.begin..other.end, other.end+1..self.end]
    elsif self.end.between?(other.begin, other.end)
      [self.begin..other.begin-1, other.begin..self.end]
    end
  end

  # Offsets a range by offset amount
  def +(offset)
    self.class.new(self.begin + offset, self.end + offset)
  end
end

# Represents a list of ranges that can be transformed by
# another list of ranges
class NoncontiguousRange
  attr_accessor :ranges

  def initialize(ranges)
    @ranges = sort(ranges)
  end

  def sort(ranges)
    return [] if ranges.nil?

    ranges.sort { |a, b| a.begin <=> b.begin }
  end

  def ==(other)
    ranges == other.ranges
  end

  def consolidate
    new_ranges = ranges.reduce([]) do |acc, range|
      last_range = acc.last

      # If they overlap or are adjacent, combine them
      if last_range &&
          last_range.end + 1 >= range.begin
        new_range = Range.new(last_range.begin, range.end)
        acc[-1] = new_range
      else
        acc << range
      end

      acc
    end

    self.class.new(new_ranges)
  end

  def intersects?(target_range)
    ranges.select do |range|
      range.intersects? target_range
    end.any?
  end

  def translate_by(from, to)
    return self unless intersects? from
    offset = to.begin - from.begin

    new_ranges = ranges.reduce([]) do |acc, current_range|
      next current_range unless current_range.intersects? from

      new_range = current_range.cut(from).map do |subrange|
        if subrange.intersects? from
          subrange + offset
        else
          subrange
        end
      end

      acc += new_range
    end

    self.class.new(new_ranges).consolidate
  end
end

class Almanac
  attr_reader :seeds

  def initialize
    @library = {}
    @seeds = []
  end

  def add_seeds(seeds)
    @seeds = seeds
  end

  def add_map(from, to)
    @library[[from, to]] = Map.new
  end

  def [](from, to)
    @library[[from, to]]
  end

  # Were I smarter or it wasn't 1:00 AM, I'd give it a
  # `from` and a final `to` and have it search through maps
  # to find a path between the two. I'm just going to
  # manually send in the list, though.
  def pipeline_value(list_of_maps, value)
    list_of_maps.reduce(value) do |acc, (from, to)|
      self[from, to].translate_value(acc)
    end
  end
end

class Map
  def initialize
    @rules = []
  end

  def add_rule(source_start, dest_start, range)
    source_range = source_start..source_start+range
    dest_range = dest_start..dest_start+range

    @rules << [source_range, dest_range]
  end

  def translate_value(source)
    rule = @rules.find { |rule| rule.first.include? source }
    if rule
      offset = source - rule.first.begin
      rule.last.begin + offset
    else
      source
    end
  end
end

def parse_input(input)
  from, to = nil
  buffer = []
  almanac = Almanac.new

  input.each do |line|
    case line
    when /^seeds: ([\d ]+)/
      seeds = Regexp.last_match
        .captures
        .first
        .split(" ")
        .map(&:to_i)
      almanac.add_seeds seeds
    when /^([a-z]+)-to-([a-z]+) map:/
      from, to = Regexp.last_match.captures
      almanac.add_map(from, to)
    when /^(\d+) (\d+) (\d+)/
      dest, source, range = Regexp.last_match
        .captures
        .map(&:to_i)
      almanac[from, to].add_rule(source, dest, range)
    end
  end

  almanac
end

PIPELINE_MAPS = [
  %w(seed soil),
  %w(soil fertilizer),
  %w(fertilizer water),
  %w(water light),
  %w(light temperature),
  %w(temperature humidity),
  %w(humidity location)
]

def star_1(almanac)
  # Translate all seeds to locations and return the lowest location's seed
  almanac.seeds.map do |seed|
    almanac.pipeline_value(PIPELINE_MAPS, seed)
  end.min
end

def star_2(almanac)
  seeds = almanac.seeds.each_slice(2).flat_map do |(start, range)|
    (start..start+range)
  end
end

if __FILE__ == $0
  file_path = File.join(File.dirname(__FILE__), 'day5.txt')
  input = parse_input(File.readlines(file_path, chomp: true))

  star_1 = star_1(input)
  star_2 = star_2(input)

  puts "Star 1: #{star_1}"
  puts "Star 2: #{star_2}"
end
