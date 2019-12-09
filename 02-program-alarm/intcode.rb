# frozen_string_literal: true

class Intcode
  attr_reader :memory
  attr_reader :pointer
  attr_writer :pointer

  def initialize(memory, noun: nil, verb: nil)
    @memory = memory
    @pointer = 0

    self.noun = noun
    self.verb = verb
  end

  def run(cycles = Float::INFINITY)
    return self if cycles.zero? || pointer.nil?

    Instruction.run(opcode: memory[pointer], intcode: self)

    run(cycles - 1)
  end

  def noun
    memory[1]
  end

  def noun=(noun)
    memory[1] = noun if noun
  end

  def verb
    memory[2]
  end

  def verb=(verb)
    memory[2] = verb if verb
  end

  def noun_verb_hash
    100 * noun + verb
  end

  class GoalSeek
    def initialize(noun_range:, verb_range:, goal:, &block)
      @noun_range = noun_range
      @verb_range = verb_range
      @goal = goal

      @create = block
    end

    def seek
      @seek ||= begin
        noun_range.each do |noun|
          verb_range.each do |verb|
            subject = create.call noun: noun, verb: verb

            return subject if subject.run.memory.first == goal
          end
        end

        raise 'not found'
      end
    end

    private

    attr_reader :create, :noun_range, :verb_range, :goal
  end
end

class Instruction
  def self.run(opcode:, intcode:)
    case opcode

    when 1
      AddInstruction
    when 2
      MultiplyInstruction
    when 99
      HaltInstruction
    else
      raise "unknown opcode #{memory[pointer]}"
    end.new(intcode).run
  end

  def initialize(intcode)
    @intcode = intcode
    @params = (1...arity).map { |n| intcode.memory[intcode.pointer + n] }
  end

  def run
    set_memory
    post_run
  end

  protected

  def post_run
    intcode.pointer += arity
  end

  def arity
    1
  end

  def operation(current)
    current
  end

  def set_memory
    return unless params.last

    intcode.memory[params.last] =
      operation(*params.map { |p| intcode.memory[p] })
  end

  private

  attr_reader :intcode, :params
end

class AddInstruction < Instruction
  def operation(left, right, _current)
    left + right
  end

  def arity
    4
  end
end

class MultiplyInstruction < Instruction
  def operation(left, right, _current)
    left * right
  end

  def arity
    4
  end
end

class HaltInstruction < Instruction
  def post_run
    intcode.pointer = nil
  end
end
