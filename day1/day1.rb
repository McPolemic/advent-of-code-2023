WORD_DIGITS = {
  'one' => 1,
  'two' => 2,
  'three' => 3,
  'four' => 4,
  'five' => 5,
  'six' => 6,
  'seven' => 7,
  'eight' => 8,
  'nine' => 9,
}

def find_digits(line) = line.chars.filter{ |c| c =~ /\d/ }.map(&:to_i)
def calibration_value(digits) = [digits.first, digits.last].map(&:to_s).join.to_i

def find_digits_and_words(line)
  values = []

  line.length.times.each do |i|
    if line[i] =~ /\d/
      values << line[i].to_i
      next
    end

    WORD_DIGITS.each do |word, num|
      if line[i..-1].start_with? word
        values << num
        break
      end
    end
  end

  values
end

if __FILE__ == $0
  file_path = File.join(File.dirname(__FILE__), 'day1.txt')
  input = File.readlines(file_path, chomp: true)

  star_1 = input.map{ |line| calibration_value(find_digits(line)) }.sum
  star_2 = input.map{ |line| calibration_value(find_digits_and_words(line)) }.sum

  puts "Star 1: #{star_1}"
  puts "Star 2: #{star_2}"
end
