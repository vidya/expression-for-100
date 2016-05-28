
# https://adriann.github.io/programming_problems.html
#
# Write a program that outputs all possibilities to put + or - or nothing between
# the numbers 1,2,…,9 (in this order) such that the result is 100.
# For example 1 + 2 + 3 - 4 + 5 + 6 + 78 + 9 = 100.

require 'pry'

module ExpressionUtil
  def to_s
    slots.reduce("expression: ") do |memo, s|
      if s.is_a?(Fixnum)
        memo << "#{s}"
      else
        memo << {
            empty:  '',
            plus:   ' + ',
            minus:  ' - '
        }[s]
      end
    end
  end
end


class SmallExpression
  include ExpressionUtil

  attr_accessor :terms, :slots

  def initialize(digit_count, operators)
    raise "Error: incorrect digit_count = #{digit_count}" unless (digit_count >= 1) && (digit_count <= 9)

    raise "Error: not enough digits: (digit_count, operator_count) = (#{digit_count}, #{operators.size})" \
      unless operators.size.eql?(digit_count  - 1)

    @terms = []

    # all but the last digit is preceded by an operator
    (1...digit_count).each do |n|
      terms << n
      terms << operators.shift #unless operators.empty?
    end

    # append the last digit
    terms << digit_count

    @slots = terms
  end

  def value
    # puts "smallExpression: #{self.to_s}"
    tmp_terms = terms.dup

    result = tmp_terms.shift

    loop do
      break if tmp_terms.empty?

      operator = tmp_terms.shift

      case operator
      when :empty
        result *= 10
        result += tmp_terms.shift

      when :plus
        next_term = tmp_terms.shift
        loop do
          break if tmp_terms.empty?
          break unless tmp_terms.first.eql?(:empty)

          next_term *= 10
          tmp_terms.shift

          next_term += tmp_terms.shift
        end

        result += next_term

      when :minus
        next_term = tmp_terms.shift
        loop do
          break if tmp_terms.empty?
          break unless tmp_terms.first.eql?(:empty)

          next_term *= 10
          tmp_terms.shift

          next_term += tmp_terms.shift
        end

        result -= next_term
      end
    end

    result
  end
end

class TestExpression
  include ExpressionUtil

  attr_accessor :slots

  def initialize(operators = Array.new(8, :empty))
    @slots = (1..8).reduce([]) do |memo, digit|
      memo << digit
      memo << operators.shift
    end

    @slots << 9
  end

  def is_last_expression?
    # are all operators :minus?
    # note that operators are arranged as [:empty, :plus, :minus]
    # operators.all? { |op| op.eql?(:minus) }
    operator_list().all? { |op| op.eql?(:minus) }
  end

  def operator_list
    slots.select { |s| s.is_a? Symbol }
  end

  def next_expression
    return nil if is_last_expression?

    op_list = operator_list()
    new_op_list = op_list.dup

    position = op_list.size - 1
    while (position >= 0)  do
      op_at_position = op_list[position]

      if op_at_position.eql?(:minus)
        position -= 1
        next
      else
        # replace operator at position with the next one
        # in the sequence [:empty, : plus, :minus]

        new_op_list[position] = {
                      :empty  => :plus,
                      :plus   => :minus,
                    }[op_at_position]

        # in the subsequent positions, start over with :empty
        ((position + 1)..8).each { |pos| new_op_list[pos] = :empty }

        new_te = TestExpression.new(new_op_list)

        return new_te
      end
    end

    binding.pry
    raise "ERROR: next_express(): unexpected flow of control" unless pos_to_modify
  end

  def ==(other_expression)
    operator_list.eql?(other_expression.operator_list)
  end

  def value
    se = SmallExpression.new(9, operator_list())
    se.value()
  end

  #--- begin: class methods
  def self.with_value_100()
    expression = TestExpression.new([
                                            :empty,  :empty,  :empty,
                                            :empty,  :empty,  :empty,
                                            :empty,  :empty
                                          ])

    count = 0
    new_expression = nil
    hundred_exp_count = 0

    loop do
      break if expression.is_last_expression?

      # puts "(count, value, expression) = (#{count}, #{expression.value}, #{expression.to_s})"

      if expression.value.eql?(100)
        hundred_exp_count += 1

        puts
        puts "--- #{hundred_exp_count} --------------------------------------------------------------------"
        puts "(count, value, expression) = (#{count}, #{expression.value}, #{expression.to_s})"
        puts "-----------------------------------------------------------------------"
        puts
      end

      new_expression = expression.next_expression()

      expression = new_expression

      count += 1
    end
  end
  #-- end: class methods
  
end

