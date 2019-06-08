# https://adriann.github.io/programming_problems.html
#
# Write a program that outputs all possibilities to put + or - or nothing between
# the numbers 1,2,…,9 (in this order) such that the result is 100.
# For example 1 + 2 + 3 - 4 + 5 + 6 + 78 + 9 = 100.

require 'pry'

module ExpressionUtil
  OP_STRING = {
      empty:  '',
      plus:   ' + ',
      minus:  ' - '
  }

  def to_s
    slots.reduce("expression: ") do |memo, s|
      if s.is_a?(Fixnum)
        memo << "#{s}"
      else
        memo << OP_STRING[s]
      end
    end
  end
end


class TestExpression
  include ExpressionUtil

  attr_accessor :slots

  def initialize(operators = Array.new(8, :empty))
    @slots = (1..8).reduce([]) { |m, digit| m << digit << operators.shift }

    @slots << 9
  end

  def operator_list
    slots.select { |s| s.is_a? Symbol }
  end

  def is_last_expression?
    # are all operators :minus?
    # note that operators are arranged as [:empty, :plus, :minus]
    operator_list.all? { |op| op.eql?(:minus) }
  end

  def next_expression
    return nil if is_last_expression?

    ops = operator_list

    empty_to_right = -> n { (n + 1).upto(ops.size) { |k| ops[k] = :empty }}

    ops.size.downto(0) do |n|
      case ops[n]
      when :empty
        ops[n] = :plus
        empty_to_right.(n)

        return TestExpression.new(ops)

      when :plus
        ops[n] = :minus
        empty_to_right.(n)

        return TestExpression.new(ops)

      # when :minus
      else
        next
      end
    end

    raise "ERROR: next_express(): unexpected flow of control"
  end

  def ==(other_expression)
    operator_list.eql?(other_expression.operator_list)
  end

  def value
    pos = 0

    next_num = -> do
      tnum = slots[pos]

      while pos < slots.size
        pos += 1
        return tnum unless slots[pos].eql?(:empty)

        pos += 1
        tnum = tnum * 10 + slots[pos]
      end
    end

    while pos < slots.size
      if slots[pos].is_a?(Fixnum)
        num = next_num.()
      else
        # slot has either :plus or :minus
        sign = slots[pos]
        pos += 1

        if sign.eql?(:plus)
          num += next_num.()
        else
          num -= next_num.()
        end
      end
    end

    num
  end

  def self.generate_100_expression
    expression = TestExpression.new([
                                        :empty,  :empty,  :empty,
                                        :empty,  :empty,  :empty,
                                        :empty,  :empty
                                    ])

    count = 0
    hundred_exp_count = 0
    until expression.is_last_expression?
      if expression.value.eql?(100)
        hundred_exp_count += 1
        yield hundred_exp_count, count, expression
      end

      expression = expression.next_expression
      count += 1
    end
  end

  def self.get_value_100_expressions()
    value_100_expressions = []

    generate_100_expression do |hundred_exp_count, count, expression|
      puts
      puts "--- #{hundred_exp_count} --------------------------------------------------------------------"
      puts "(count, value, expression) = (#{count}, #{expression.value}, #{expression.to_s})"
      puts "-----------------------------------------------------------------------"
      puts

      value_100_expressions << expression
    end

    value_100_expressions
  end

end

