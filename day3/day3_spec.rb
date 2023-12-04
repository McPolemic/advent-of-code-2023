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

      xcontext 'with a horizontal range' do
        let(:grid) { Grid.new([[1, 2, 3, 4, 5],
                               [6, 7, 8, 9, 0],
                               [1, 2, 3, 4, 5]]) }

        it 'enumerates through surrounding coordinates' do
          coords = []
          expected = [[0, 0], [1, 0], [2, 0], [3, 0], [4, 0],
                      [0, 1],                         [4, 1],
                      [0, 2], [1, 2], [2, 2], [3, 2], [4, 2]]

          coords = grid.surrounding_coords([1,1], [3,1]) do |coord|
            coords << coord
          end

          expect(coords).to eq expected
        end
      end
    end

    describe 'numbers_at' do
      context "when the coordinates point to one number" do
        let(:grid) { Grid.new([['.', '2', '.'],
                               ['.', '.', '.'],
                               ['.', '.', '.']]) }

        it "return the numbers" do
          expect(grid.numbers_at([[1, 0]])).to eq [2]
        end
      end

      context "when multiple coordinates point to the same number" do
        it "return a single number"
      end
    end
  end

  describe 'find_numbers' do
    context 'when no numbers are found' do
      let (:grid) { Grid.new([['.', '.', '.'],
                              ['.', '.', '.'],
                              ['.', '.', '.']]) }
      it 'returns nothing if no numbers are found' do
        expect(find_numbers(grid)).to be_empty
      end
    end

    context 'when numbers are single-digit' do
      let (:grid) { Grid.new([['1', '.', '2'],
                              ['.', '.', '.'],
                              ['.', '3', '.']]) }
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
      let (:grid) { Grid.new([['1', '2', '.'],
                              ['.', '.', '.'],
                              ['.', '3', '4']]) }
      it 'returns CoordinateMatches for each number found' do
        number_matches = find_numbers(grid)

        numbers = number_matches.map(&:value)

        expect(numbers).to eq [12, 34]
        expect(number_matches[0].coordinates).to eq [[0,0], [1,0]]
        expect(number_matches[1].coordinates).to eq [[1,2], [2,2]]
      end
    end
  end
end
