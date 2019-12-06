# frozen_string_literal: true

class RocketModule
  def initialize(mass:, strategy: NaiveCalculator.new)
    @mass = mass
    @strategy = strategy
  end

  def fuel_requirement
    strategy.calculate(mass)
  end

  private

  attr_reader :mass, :strategy

  class Collection
    def self.for(mass_list, strategy: NaiveCalculator.new)
      modules = mass_list.map do |mass|
        RocketModule.new(mass: mass, strategy: strategy)
      end
      new(modules)
    end

    def initialize(modules)
      @modules = modules
    end

    def fuel_requirement
      modules.sum(&:fuel_requirement)
    end

    private

    attr_reader :modules
  end

  class NaiveCalculator
    def calculate(mass)
      (mass.to_f / 3).floor - 2
    end
  end

  class CompoundCalculator
    def calculate(mass)
      return 0 if mass.zero?

      fuel = [(mass.to_f / 3).floor - 2, 0].max
      fuel + calculate(fuel)
    end
  end
end
