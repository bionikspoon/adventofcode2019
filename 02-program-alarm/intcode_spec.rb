# frozen_string_literal: true

require_relative 'intcode'

RSpec.describe Intcode do
  describe '#run' do
    it 'can be a noop' do
      intcode =  described_class.new([99])

      expect(intcode.run.memory).to eq([99])
    end

    it 'can add' do
      intcode =  described_class.new([1, 0, 0, 0, 99])

      expect(intcode.run.memory).to eq([2, 0, 0, 0, 99])
    end

    it 'can multiply' do
      intcode = described_class.new([2, 3, 0, 3, 99])

      expect(intcode.run.memory).to eq([2, 3, 0, 6, 99])
    end

    it 'can stop' do
      intcode = described_class.new([2, 4, 4, 5, 99, 0])

      expect(intcode.run.memory).to eq([2, 4, 4, 5, 99, 9801])
    end

    it 'can dive into itself' do
      intcode = described_class.new([1, 1, 1, 4, 99, 5, 6, 0, 99])

      expect(intcode.run.memory).to eq([30, 1, 1, 4, 2, 5, 6, 0, 99])
    end

    it 'can step through memory' do
      intcode = described_class.new([1, 9, 10, 3, 2, 3, 11, 0, 99, 30, 40, 50])

      aggregate_failures do
        expect(intcode.run(1).memory).to eq([1, 9, 10, 70, 2, 3, 11, 0, 99, 30, 40, 50])
        expect(intcode.run(1).memory).to eq([3500, 9, 10, 70, 2, 3, 11, 0, 99, 30, 40, 50])
        expect(intcode.run(1).memory).to eq([3500, 9, 10, 70, 2, 3, 11, 0, 99, 30, 40, 50])
      end
    end

    it 'can run on input.txt' do
      input = File.readlines(File.join(__dir__, 'input.txt')).join(',').chomp.split(',').map(&:to_i)

      intcode = described_class.new(input, noun: 12, verb: 2)

      expect(intcode.run.memory.first).to be(5_305_097)
    end
  end

  describe Intcode::GoalSeek do
    describe '#seek' do
      subject(:goalseek) do
        described_class.new(noun_range: (0..99), verb_range: (0..99), goal: 19_690_720) do |noun:, verb:|
          Intcode.new(input.dup, noun: noun, verb: verb)
        end
      end

      let(:input) { File.readlines(File.join(__dir__, 'input.txt')).join(',').chomp.split(',').map(&:to_i) }

      it 'can iterate through nouns and verbs' do
        expect(goalseek.seek).to have_attributes(noun: 49, verb: 25, noun_verb_hash: 4925)
      end
    end
  end
end
