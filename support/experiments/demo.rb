#!/usr/bin/env ruby

require 'rubygems'
require 'ripper'
require 'sorcerer'

class EvalErr
  def initialize(str)
    @string = str
  end
  def size
    inspect.size
  end
  def to_s
    @string
  end
  def inspect
    @string
  end
end

def eval_in(exp, binding)
  eval(exp, binding).inspect
rescue StandardError => ex
  EvalErr.new("#{ex.class}: #{ex.message}")
end

def suggest_width(pairs)
  pairs.map { |x,v| v.size }.select { |n| n < 20 }.max || 10
end

def display_pairs(pairs)
  width = suggest_width(pairs)
  pairs.each do |x, v|
    if v.size > 20
      printf "  %-#{width+2}s\n  #{' '*(width+2)} <- %s\n", v, x
    else
      printf "  %-#{width+2}s <- %s\n", v, x
    end
  end
end

def caller_line
  file, line = caller[1].split(/:/)
  [file, line]
end

require 'pp'

def evaluate(&block)
  file, line = caller_line
  puts "Evaluating all expressions and subexpressions on #{file}:#{line}"
  lines = open(file).readlines
  code = lines[line.to_i-1]
  sexp = Ripper::SexpBuilder.new(code).parse
  sexp = sexp[1][2][2][2]
  subs = Sorcerer.subexpressions(sexp).reverse.uniq.reverse
  pairs = subs.map { |exp|
    [exp, eval_in(exp, block.binding)]
  }
  display_pairs(pairs)
  puts
end

def f(n)
  n*n
end

# Define a bunch of variables

a = 10
b = 2
c = 11
n = nil
p = ->(n) { n*n }
x = 'xyzzy'
hi = "hello"
there = "world"


evaluate { 132 == (a + b) * c and x =~ /z+/ }

evaluate { f(f(f(f(a)))) * f(f(b)) }

evaluate { Math.sin(0.7) > 0.6 && Math.sin(0.7) < 0.8 }

evaluate { [4, 2, 6, 3, 7].sort.select { |n| n % 2 == 0 }.collect { |n| n*n } }

evaluate { hi.upcase + ', ' + there.capitalize }

evaluate { hi.upcase + ', ' + there.capitalize + n.downcase }

evaluate { a == b }

evaluate { p.(b) } if RUBY_VERSION >= "1.9.2"

evaluate { a && (a+=2) && a }

p = lambda { a == b }
evaluate(&p)
