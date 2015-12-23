begin
  require 'ripper'
  require 'sorcerer'
rescue LoadError
  # NOTE: on Rubinius or old JRuby, Ripper isn't available
  warn <<-WARNING
rspec-given: WARNING: Sorcerer is not available, so in case of a failing Then
clause, only its FIRST LINE of source will be printed, no matter how many
lines it actually spans.
  WARNING
end
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
      return result if ! defined?(::Sorcerer)
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
    rescue Sorcerer::Resource::NotSexpError
      false
    end

    def parse(string)
      Ripper::SexpBuilder.new(string).parse
    end
  end
end
