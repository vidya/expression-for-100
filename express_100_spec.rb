require 'pry'
require_relative 'express_100'

describe TestExpression do
  attr_accessor :expression, :slots, :digits, :operators

  before(:example) do
    @expression = TestExpression.new
    @slots = @expression.slots

    @operators = slots.partition { |s| s.is_a? Symbol }.first
  end

  it "should return a next expression correctly" do
    te = TestExpression.new([
                              :empty,  :minus,  :minus,
                              :minus,  :minus,  :minus,
                              :minus,  :minus
                            ])

    next_te = TestExpression.new([
                                    :plus,  :empty,  :empty,
                                    :empty,  :empty,  :empty,
                                    :empty,  :empty
                                  ])

    expect(te.next_expression == next_te).to be_truthy
  end

  it "should work well" do
    te = TestExpression.new([
                              :empty,  :empty,  :empty,
                              :empty,  :plus,  :minus,
                              :empty,  :empty
                            ])

    expect(te.value()).to eq(11562)
  end

  it "should have 8 operators" do
    expect(operators.size).to eq(8)
  end

  it "should create expressions with an arbitrary list of operators" do
    operator_list = [
        :empty, :plus, :plus,
        :plus, :plus, :plus,
        :plus, :plus, :plus,
    ]

    te = TestExpression.new(operator_list)
    @digits, @operators = te.slots.partition { |s| s.is_a? Fixnum }

    expect(digits.size).to eq(9)
    expect(operators.size).to eq(8)
  end

  it "should evaluate expressions with an arbitrary list of operators" do
    te = TestExpression.new([
                              :plus,  :plus,  :plus,
                              :plus,  :plus,  :plus,
                              :plus,  :plus
                            ])

    expect(te.value()).to eq(45)

    te = TestExpression.new([
                              :plus,  :plus,  :plus,
                              :plus,  :plus,  :plus,
                              :plus,  :minus
                            ])

    expect(te.value()).to eq(27)
  end

  context "when generating expressions in a sequence" do
    it "should recognize the last expression" do
      te = TestExpression.new([
                                :minus,  :minus,  :minus,
                                :minus,  :minus,  :minus,
                                :minus,  :minus
                              ])

      expect(te.is_last_expression?).to be_truthy
  
      te = TestExpression.new([
                                :plus,  :plus,  :plus,
                                :plus,  :plus,  :plus,
                                :plus,  :minus
                              ])

      expect(te.is_last_expression?).to be_falsey
    end

    it "should not return any expressions after the last expression" do
      last_expression = TestExpression.new([
                                              :minus,  :minus,  :minus,
                                              :minus,  :minus,  :minus,
                                              :minus,  :minus
                                            ])
      expect(last_expression.next_expression).to be_nil
    end

    it "should return a next expression correctly" do
      te = TestExpression.new([
                                :minus,  :minus,  :minus,
                                :minus,  :empty,  :minus,
                                :minus,  :minus
                              ])

      next_te = TestExpression.new([
                                      :minus,  :minus,  :minus,
                                      :minus,  :plus,  :empty,
                                      :empty,  :empty
                                    ])

      expect(te.next_expression == next_te).to be_truthy
    end
  end

  it "gets an expression with value 100" do
    TestExpression.with_value_100()
    true
  end
end

describe SmallExpression do
  it "can create a SmallExpression object" do
    expect { SmallExpression.new(4, [:plus]) }.to raise_error(/Error: not enough digits/)
  end

  it "can evaluate a small expression" do
    # 1 + 2
    se = SmallExpression.new(2, [:plus])
    expect(se.value()).to eq(3)

    # 1 + 2 + 3 + 4 + 5
    se = SmallExpression.new(5,[:plus, :plus, :plus, :plus])
    expect(se.value()).to eq(15)

    # 1 - 2 + 3 + 4 - 5
    se = SmallExpression.new(5,[:minus, :plus, :plus, :minus])
    expect(se.value()).to eq(1)

    # (1 2) + 3 + 4 - 5
    se = SmallExpression.new(5,[:empty, :plus, :plus, :minus])
    expect(se.value()).to eq(14)
  end

end
