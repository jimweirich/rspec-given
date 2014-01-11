require 'ripper'
require 'sorcerer'
require 'given/file_cache'

module Given
  class LineExtractor
    def initialize(file_cache=nil)
      @files = file_cache || FileCache.new
    end

    def line(file_name, line)
      lines = @files.get(file_name)
      extract_lines_from(lines, line-1)
    end

    def to_s
      "<LineExtractor>"
    end

    private

    def extract_lines_from(lines, line_index)
      result = lines[line_index]
      while result && incomplete?(result)
        line_index += 1
        result << lines[line_index]
      end
      result
    end

    def incomplete?(string)
      ! complete_sexp?(parse(string))
    end

    def complete_sexp?(sexp)
      Sorcerer.source(sexp)
      true
    rescue Sorcerer::Resource::NotSexpError => ex
      false
    end

    def parse(string)
      Ripper::SexpBuilder.new(string).parse
    end
  end
end
