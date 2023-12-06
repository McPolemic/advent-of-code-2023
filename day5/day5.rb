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
  def pipeline(list_of_maps, source)
    list_of_maps.reduce(source) do |acc, (from, to)|
      self[from, to].translate(acc)
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

  def translate(source)
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
    almanac.pipeline(PIPELINE_MAPS, seed)
  end.min
end

def star_2(almanac)
  seeds = almanac.seeds.each_slice(2).flat_map do |(start, range)|
    (start..start+range).to_a
  end

  seeds.map do |seed|
    almanac.pipeline(PIPELINE_MAPS, seed)
  end.min
end

if __FILE__ == $0
  file_path = File.join(File.dirname(__FILE__), 'day5.txt')
  input = parse_input(File.readlines(file_path, chomp: true))

  star_1 = star_1(input)
  star_2 = star_2(input)

  puts "Star 1: #{star_1}"
  puts "Star 2: #{star_2}"
end
