require 'rspec'
require_relative './day5'

RSpec.describe Range do
  describe '#intersects?' do
    it 'returns true if the other range intersects' do
      input = 10..100

      # Covered by range
      expect(input.intersects?(40..50)).to be true
      # Beginning covered
      expect(input.intersects?(1..15)).to be true
      # Ending covered
      expect(input.intersects?(90..105)).to be true
      # Completely overlaps
      expect(input.intersects?(1..1000)).to be true
    end

    it 'returns false if it does not intersect' do
      input = 10..100

      # Before the input range
      expect(input.intersects?(0..5)).to be false
      # After the input range
      expect(input.intersects?(1000..1500)).to be false
    end
  end

  describe '#cut' do
    context 'when the other range does not intersect' do
      it 'returns an array of the original range' do
        input = 10..100

        result = input.cut(0..5)
        expect(result).to eq [input]

        result = input.cut(10000..1000000)
        expect(result).to eq [input]
      end
    end

    context 'when the other range completely overlaps' do
      it 'returns an array of the original range' do
        input = 10..100

        result = input.cut(0..1000)
        expect(result).to eq [input]
      end
    end

    context 'when the other range intersects at the beginning' do
      it 'returns an array of two ranges, intersection and after intersection' do
        input = 10..100

        result = input.cut(0..50)
        expect(result).to eq [10..50, 51..100]
      end
    end

    context 'when the other range intersects in the middle' do
      it 'returns an array of three ranges (before intersection, middle intersection,after intersection' do
        input = 10..100

        result = input.cut(50..60)
        expect(result).to eq [10..49, 50..60, 61..100]
      end
    end

    context 'when the other range intersects at the end' do
      it 'returns an array of two ranges, before intersection and after intersection' do
        input = 10..100

        result = input.cut(50..150)
        expect(result).to eq [10..49, 50..100]
      end
    end
  end

  describe '#+' do
    it 'increases a range by an offset' do
      input = 1..10
      expect(input + 10).to eq 11..20
    end
  end
end

RSpec.describe 'Day5' do
  describe NoncontiguousRange do
    describe '#initialize' do
      it 'sorts input ranges' do
        input = NoncontiguousRange.new([10..20, 1..5])
        expected_ranges = [1..5, 10..20]

        expect(input.ranges).to eq expected_ranges
      end
    end

    describe '#consolidate' do
      it 'leaves non-adjacent ranges alone' do
        input = NoncontiguousRange.new([1..5, 10..20])

        result = input.consolidate

        expect(result).to eq input
      end

      it 'consolidates adjacent ranges' do
        input = NoncontiguousRange.new([1..5, 6..10])

        result = input.consolidate

        expect(result.ranges).to eq [1..10]
      end

      it 'consolidates overlapping ranges' do
        input = NoncontiguousRange.new([1..5, 2..10])

        result = input.consolidate

        expect(result.ranges).to eq [1..10]
      end

      it 'consolidates multiple ranges at once' do
        input = NoncontiguousRange.new(
          [1..5, 6..10, 25..100, 100..102, 105..107]
        )
        expected_ranges = [1..10, 25..102, 105..107]

        result = input.consolidate

        expect(result.ranges).to eq expected_ranges
      end
    end

    describe '#intersects?' do
      it 'returns true if a range intersects' do
        input = NoncontiguousRange.new([-10..0, 10..100])

        # Covered by range
        expect(input.intersects?(40..50)).to be true
        # Beginning covered
        expect(input.intersects?(1..15)).to be true
        # Ending covered
        expect(input.intersects?(90..105)).to be true
        # Completely overlaps
        expect(input.intersects?(1..1000)).to be true
      end

      it 'returns false if a range does not intersects' do
        input = NoncontiguousRange.new([1..100])

        expect(input.intersects?(1000..1040)).to be false
      end
    end

    describe '#translate_by' do
      context 'when from completely covers the range' do
        it 'translates directly' do
          input = NoncontiguousRange.new([1..5, 8..10])

          result = input.translate_by(1..100, 1001..1100)

          expect(result.ranges).to match_array [1001..1005, 1008..1010]
        end
      end

      context 'when from partially covers the ranges' do
        it 'splits the range and offsets what applies' do
          input = NoncontiguousRange.new([1..5, 8..10])
          expected = [1..3, 1004..1005, 1008..1009, 10..10]

          result = input.translate_by(4..9, 1004..1009)

          expect(result.ranges).to match_array expected
        end
      end

      context 'when the translation_ranges does not cover the ranges' do
        it 'returns unchanged' do
          input = NoncontiguousRange.new([1..5, 8..10])

          result = input.translate_by(1000..1050, 2000..2050)

          expect(result).to eq input
        end
      end
    end
  end
end
