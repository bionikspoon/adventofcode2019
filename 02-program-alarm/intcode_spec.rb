# frozen_string_literal: true

require_relative 'intcode'

RSpec.describe Intcode do
  describe '#run' do
    it 'can be a noop' do
      subject =  described_class.new([99])

      expect(subject.run.state).to eq([99])
    end

    it 'can add' do
      subject =  described_class.new([1, 0, 0, 0, 99])

      expect(subject.run.state).to eq([2, 0, 0, 0, 99])
    end

    it 'can multiply' do
      subject = described_class.new([2, 3, 0, 3, 99])

      expect(subject.run.state).to eq([2, 3, 0, 6, 99])
    end

    it 'can stop' do
      subject = described_class.new([2, 4, 4, 5, 99, 0])

      expect(subject.run.state).to eq([2, 4, 4, 5, 99, 9801])
    end

    it 'can dive into itself' do
      subject = described_class.new([1, 1, 1, 4, 99, 5, 6, 0, 99])

      expect(subject.run.state).to eq([30, 1, 1, 4, 2, 5, 6, 0, 99])
    end

    it 'can step through state' do
      subject = described_class.new([1, 9, 10, 3, 2, 3, 11, 0, 99, 30, 40, 50])

      expect(subject.run(1).state).to eq([1, 9, 10, 70, 2, 3, 11, 0, 99, 30, 40, 50])
      expect(subject.run(1).state).to eq([3500, 9, 10, 70, 2, 3, 11, 0, 99, 30, 40, 50])
      expect(subject.run(1).state).to eq([3500, 9, 10, 70, 2, 3, 11, 0, 99, 30, 40, 50])
    end

    it 'can run on input.txt' do
      input = File.readlines(File.join(__dir__, 'input.txt')).join(',').chomp.split(',').map(&:to_i)
      input[1] = 12
      input[2] = 2
      subject = described_class.new(input)

      expect(subject.run.state.first).to be(5_305_097)
    end

    it 'can iterate through nouns and verbs' do
      (0..99).each do |noun|
        (0..99).each do |verb|
          input = File.readlines(File.join(__dir__, 'input.txt')).join(',').chomp.split(',').map(&:to_i)
          input[1] = noun
          input[2] = verb
          subject = described_class.new(input)

          next unless subject.run.state.first == 19_690_720

          aggregate_failures do
            expect(noun).to be(49)
            expect(verb).to be(25)

            expect(100 * noun + verb).to be(4925)
          end
        end
      end
    end
  end
end
