require 'rspec'
require_relative './day3'

RSpec.describe 'Day3' do
  describe Grid do
    let(:grid) { Grid.new([[1, 2, 3],
                           [4, 5, 6]]) }
    describe '#at' do
      it 'finds the character at a given coordinates' do
        expect(grid.at(0, 0)).to eq 1
        expect(grid.at(1, 0)).to eq 2
        expect(grid.at(2, 0)).to eq 3
        expect(grid.at(0, 1)).to eq 4
        expect(grid.at(1, 1)).to eq 5
        expect(grid.at(2, 1)).to eq 6
      end

      it 'returns nil if the coordinates are out of bounds' do
        expect(grid.at(-1, 0)).to eq nil
        expect(grid.at(0, -1)).to eq nil
        expect(grid.at(100, 0)).to eq nil
        expect(grid.at(0, 100)).to eq nil
      end
    end

    describe '#each' do
      it 'enumerates through grid values' do
        values = []

        grid.each do |char|
          values << char
        end

        expect(values).to eq [1, 2, 3, 4, 5, 6]
      end

      it 'also includes the coordinates' do
        coords = []

        grid.each do |_, coord|
          coords << coord
        end

        expect(coords).to eq [[0, 0], [1, 0], [2, 0],
                              [0, 1], [1, 1], [2, 1]]
      end
    end

    describe '#surrounding_coords' do
      context 'with a single point' do
        let(:grid) { Grid.new([[1, 2, 3],
                               [4, 5, 6],
                               [7, 8, 9]]) }

        it 'enumerates through surrounding coordinates' do
          expected = [[0, 0], [1, 0], [2, 0],
                      [0, 1],         [2, 1],
                      [0, 2], [1, 2], [2, 2]]

          coords = grid.surrounding_coords([1,1], [1,1])

          expect(coords).to eq expected
        end
      end

      context 'with a horizontal range' do
        let(:grid) { Grid.new([[1, 2, 3, 4, 5],
                               [6, 7, 8, 9, 0],
                               [1, 2, 3, 4, 5]]) }

        it 'enumerates through surrounding coordinates' do
          expected = [[0, 0], [1, 0], [2, 0], [3, 0], [4, 0],
                      [0, 1],                         [4, 1],
                      [0, 2], [1, 2], [2, 2], [3, 2], [4, 2]]

          coords = grid.surrounding_coords([1,1], [3,1])

          expect(coords).to eq expected
        end
      end
    end

    describe '#surrounding_values' do
      context 'with a single point' do
        let(:grid) { Grid.new([[1, 2, 3],
                               [4, 5, 6],
                               [7, 8, 9]]) }

        it 'enumerates through surrounding coordinates' do
          expected = [1, 2, 3,
                      4,    6,
                      7, 8, 9]

          values = grid.surrounding_values([1,1], [1,1])

          expect(values).to match_array expected
        end
      end

      context 'with a horizontal range' do
        let(:grid) { Grid.new([%w[0 1 2 3 4],
                               %w[5 6 7 8 9],
                               %w[a b c d e]]) }

        it 'enumerates through surrounding coordinates' do
          expected = %w(0 1 2 3 4
                        5       9
                        a b c d e)

          values = grid.surrounding_values([1,1], [3,1])

          expect(values).to match_array expected
        end
      end
    end
  end

  describe 'find_numbers' do
    context 'when no numbers are found' do
      let (:grid) { Grid.new([%w[. . .],
                              %w[. . .],
                              %w[. . .]]) }
      it 'returns nothing if no numbers are found' do
        expect(find_numbers(grid)).to be_empty
      end
    end

    context 'when numbers are single-digit' do
      let (:grid) { Grid.new([%w[1 . 2],
                              %w[. . .],
                              %w[. 3 .]]) }
      it 'returns CoordinateMatch for each number found' do
        number_matches = find_numbers(grid)

        numbers = number_matches.map(&:value)
        starts = number_matches.map(&:start)
        finishes = number_matches.map(&:finish)

        expect(numbers).to eq [1, 2, 3]
        # Each number is one character long, so the starting
        # index should equal the finishing offset
        expect(starts).to eq finishes
      end
    end

    context 'when numbers are multi-digit' do
      let (:grid) { Grid.new([%w[1 2 .],
                              %w[. . .],
                              %w[. 3 4]]) }
      it 'returns CoordinateMatches for each number found' do
        number_matches = find_numbers(grid)

        numbers = number_matches.map(&:value)

        expect(numbers).to eq [12, 34]
        expect(number_matches[0].coordinates).to eq [[0,0], [1,0]]
        expect(number_matches[1].coordinates).to eq [[1,2], [2,2]]
      end
    end
  end

  describe '#find_valid_numbers' do
    context 'when there is punctuation around' do
      it 'returns the numbers near punctuation' do
        grid = Grid.new([%w[@ . .],
                         %w[. 4 .],
                         %w[. . .]])

        result = find_valid_numbers(grid)

        expect(result).to eq [4]
      end

      it 'works with larger numbers' do
        grid = Grid.new([%w[@ . . .],
                         %w[. 4 5 .],
                         %w[. . . .]])

        result = find_valid_numbers(grid)

        expect(result).to eq [45]
      end

      it 'works with multiple numbers' do
        grid = Grid.new([%w[@ . . . .],
                         %w[. 4 5 . .],
                         %w[. . . . .],
                         %w[. . 5 1 2],
                         %w[. . . * .]])

        result = find_valid_numbers(grid)

        expect(result).to eq [45, 512]
      end
    end

    context 'when there is not punctuation around' do
      it 'returns nothing if no numbers are found' do
        grid = Grid.new([%w[. . .],
                         %w[. 4 .],
                         %w[. . .]])

        result = find_valid_numbers(grid)

        expect(result).to be_empty
      end
    end

    context 'Star 1 Example' do
      it 'finds all valid numbers' do
        grid = Grid.new([%w[4 6 7 . . 1 1 4 . .],
                         %w[. . . * . . . . . .],
                         %w[. . 3 5 . . 6 3 3 .],
                         %w[. . . . . . # . . .],
                         %w[6 1 7 * . . . . . .],
                         %w[. . . . . + . 5 8 .],
                         %w[. . 5 9 2 . . . . .],
                         %w[. . . . . . 7 5 5 .],
                         %w[. . . $ . * . . . .],
                         %w[. 6 6 4 . 5 9 8 . .]])
        expected = [467, 35, 633, 617, 592, 755, 664, 598]

        result = find_valid_numbers(grid)

        expect(result).to match_array expected
      end
    end
  end

  describe 'Star 1 Example' do
    let (:grid) { Grid.new([%w[4 6 7 . . 1 1 4 . .],
                            %w[. . . * . . . . . .],
                            %w[. . 3 5 . . 6 3 3 .],
                            %w[. . . . . . # . . .],
                            %w[6 1 7 * . . . . . .],
                            %w[. . . . . + . 5 8 .],
                            %w[. . 5 9 2 . . . . .],
                            %w[. . . . . . 7 5 5 .],
                            %w[. . . $ . * . . . .],
                            %w[. 6 6 4 . 5 9 8 . .]]) }

    it 'finds the answer' do
      result = find_valid_numbers(grid).sum

      expect(result).to eq 4361
    end
  end
end
