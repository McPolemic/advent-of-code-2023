
if __FILE__ == $0
  file_path = File.join(File.dirname(__FILE__), 'day5.txt')
  input = File.readlines(file_path, chomp: true).map(&:chars)

  star_1 = find_valid_numbers(Grid.new(input)).sum
  star_2 = "You know, life's too short to worry about some things."

  puts "Star 1: #{star_1}"
  puts "Star 2: #{star_2}"
end
