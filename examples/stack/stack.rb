class Stack
  class StackError < StandardError; end
  class UnderflowError < StackError; end

  def initialize
    @items = []
  end

  def depth
    @items.size
  end

  def empty?
    @items.empty?
  end

  def top
    @items.last
  end

  def push(item)
    @items << item
  end

  def pop
    fail UnderflowError, "Cannot pop an empty stack" if empty?
    @items.pop
  end
end
