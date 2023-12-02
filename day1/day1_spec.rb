require 'rspec'
require './day1'

RSpec.describe 'Day1' do
  describe '#find_digits' do
    it 'pulls out all digits' do
      result = find_digits('a1anda2anda3anda4')
      expect(result).to eq [1,2,3,4]
    end
  end

  describe '#calibration_value' do
    it 'returns the first and last number as a new integer' do
      result = calibration_value([1,2,3,4])
      expect(result).to eq 14
    end
  end
  
  describe '#find_digits_and_words' do
    it 'can find digits!' do
      result = find_digits_and_words('a1anda2anda3anda4')
      expect(result).to eq [1,2,3,4]
    end

    it 'can find words!' do
      result = find_digits_and_words('a one and a two and a three and a four')
      expect(result).to eq [1,2,3,4]
    end

    it 'can find words and digits!' do
      result = find_digits_and_words('a 1 and a two and a three and a 4')
      expect(result).to eq [1,2,3,4]
    end

    it 'can find multiple digits in combined words' do
      result = find_digits_and_words('eightwo')
      expect(result).to eq [8,2]
    end
  end

  it 'can find the calibration value for star 1 example' do
    input = <<~EOF.lines(chomp: true)
      1abc2
      pqr3stu8vwx
      a1b2c3d4e5f
      treb7uchet
    EOF

    result = input.map{ |line| calibration_value(find_digits(line)) }.sum
    expect(result).to eq 142
  end

  it 'can find the calibration value for star 2 example' do
    input = <<~EOF.lines(chomp: true)
      two1nine
      eightwothree
      abcone2threexyz
      xtwone3four
      4nineeightseven2
      zoneight234
      7pqrstsixteen
    EOF

    result = input.map{ |line| calibration_value(find_digits_and_words(line)) }.sum
    expect(result).to eq 281
  end
end
