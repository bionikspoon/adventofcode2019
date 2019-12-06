# frozen_string_literal: true

class Intcode
  attr_reader :state
  def initialize(state)
    @state = state
    @pointer = 0
  end

  def run(cycles = Float::INFINITY)
    return self if cycles.zero?

    case state[pointer]
    when 1
      state[state[pointer + 3]] =
        state[state[pointer + 1]] +
        state[state[pointer + 2]]
      @pointer += 4

    when 2
      state[state[pointer + 3]] =
        state[state[pointer + 1]] *
        state[state[pointer + 2]]
      @pointer += 4

    when 99
      @pointer += 1

      return self
    else
      raise "unknown opcode #{state[pointer]}"
    end

    run(cycles - 1)
  end

  private

  attr_reader :pointer
end
