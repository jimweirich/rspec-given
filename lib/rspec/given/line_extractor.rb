require 'rspec/given/file_cache'

module RSpec
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
        if continued?(result)
          level = indentation_level(result)
          begin
            line_index += 1
            result << lines[line_index]
          end while indentation_level(lines[line_index]) > level
        end
        result
      end

      def continued?(string)
        string =~ /(\{|do) *$/
      end

      def indentation_level(string)
        string =~ /^(\s*)\S/
        $1.nil? ? 1000000 : $1.size
      end
    end
  end
end
