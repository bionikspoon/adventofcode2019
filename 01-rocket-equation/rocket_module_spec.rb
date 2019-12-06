# frozen_string_literal: true

require_relative 'rocket_module'

RSpec.describe RocketModule do
  describe '#fuel_requirement' do
    it 'calculates' do
      expect(described_class.new(mass: 12).fuel_requirement).to be(2)
    end

    it 'correctly rounds' do
      expect(described_class.new(mass: 14).fuel_requirement).to be(2)
    end

    it 'works for big numbers' do
      aggregate_failures do
        expect(described_class.new(mass: 1969).fuel_requirement).to be(654)
        expect(described_class.new(mass: 100_756).fuel_requirement).to be(33_583)
      end
    end

    context 'when using a compounding calculator' do
      let(:strategy) { RocketModule::CompoundCalculator.new }

      it 'calculates' do
        aggregate_failures do
          expect(described_class.new(mass: 12, strategy: strategy).fuel_requirement).to be(2)
          expect(described_class.new(mass: 14, strategy: strategy).fuel_requirement).to be(2)
          expect(described_class.new(mass: 1969, strategy: strategy).fuel_requirement).to be(966)
          expect(described_class.new(mass: 100_756, strategy: strategy).fuel_requirement).to be(50_346)
        end
      end
    end
  end

  describe RocketModule::Collection do
    let(:mass_list) { File.readlines(File.join(__dir__, 'input.txt')).map(&:chomp).map(&:to_i) }

    describe '#fuel_requirement' do
      it 'calulates for all modules' do
        expect(described_class.for([12, 14]).fuel_requirement).to be(4)
      end

      it 'calculates for input.txt' do
        expect(described_class.for(mass_list).fuel_requirement).to be(3_497_399)
      end

      context 'when using a compounding calculator' do
        let(:strategy) { RocketModule::CompoundCalculator.new }

        it 'calculates' do
          expect(described_class.for([12, 1969], strategy: strategy).fuel_requirement).to be(2 + 966)
        end

        it 'calculates for input.txt' do
          expect(described_class.for(mass_list, strategy: strategy).fuel_requirement).to be(5_243_207)
        end
      end
    end
  end
end
