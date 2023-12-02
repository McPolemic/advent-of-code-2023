require 'rspec'
require_relative './day2'

RSpec.describe GameParser do
  let(:game) { GameParser.new(red: 12, green: 13, blue: 14) }

  describe '#valid?' do
    it 'can tell if a hint is valid' do
      id = 1
      hints = [
        {blue: 3, red: 4},
        {green: 2, blue: 6},
        {green: 2}
      ]
      result = game.valid?(id, hints)

      expect(result).to be_success
      expect(result.id).to eq id
    end

    it 'can tell if a hint is invalid' do
      id = 23
      hints = [{red: 100, green: 4}]
      result = game.valid?(id, hints)

      expect(result).to be_failure
      expect(result.id).to eq id
      expect(result.errors).to eq ["100 red is greater than 12"]
    end
  end

  describe '.parse_hint_string' do
    it 'finds the id and formats the hints for a simple game' do
      hint = 'Game 1: 3 blue, 4 red'

      id, hints = GameParser.parse_hint_string(hint)
      expect(id).to eq 1
      expect(hints).to eq [{blue: 3, red: 4}]
    end

    it 'finds the id and hints for a complex game' do
      hint = 'Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue'
      expected_hints = [
        {blue: 1, green: 2},
        {green: 3, blue: 4, red: 1},
        {green: 1, blue: 1},
      ]

      id, hints = GameParser.parse_hint_string(hint)

      expect(id).to eq 2
      expect(hints).to eq expected_hints
    end
  end

  describe '#product' do
    it 'finds the product' do
      game = GameParser.new(red: 4, green: 2, blue: 6)

      expect(game.product).to eq 48
    end
  end

  describe '.new_from_hint' do
    it 'determines max from one set' do
      hint = 'Game 1: 3 blue, 4 red'
      game = GameParser.new_from_hint(hint)

      expect(game.red).to eq 4
      expect(game.green).to eq 0
      expect(game.blue).to eq 3
    end

    it 'determines max from multiple sets' do
      hint = 'Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue'

      game = GameParser.new_from_hint(hint)

      expect(game.red).to eq 1
      expect(game.green).to eq 3
      expect(game.blue).to eq 4
    end
  end

  context 'Star 1 example' do
    it 'finds the sum of ids for valid games' do
      input = <<~EOF
        Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
        Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue
        Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red
        Game 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red
        Game 5: 6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green
      EOF

      result = input
        .lines(chomp: true)
        .map{ |hint| game.hint_string_valid?(hint) }
        .select(&:success?)
        .map(&:id)
        .sum

      expect(result).to eq 8
    end
  end

  context 'Star 2 example' do
    it 'finds the products of each game' do
      input = <<~EOF
        Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
        Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue
        Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red
        Game 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red
        Game 5: 6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green
      EOF

      result = input
        .lines(chomp: true)
        .map{ |hint| GameParser.new_from_hint(hint).product }
        .sum

      expect(result).to eq 2286
    end
  end
end
