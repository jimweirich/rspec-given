class Stack
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
    @items.pop
  end
end
