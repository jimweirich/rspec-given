module RSpec
  module Given
    class LineCache
      def initialize
        @lines = {}
      end

      def line(file_name, line)
        lines = get_lines(file_name)
        extract_lines_from(lines, line-1)
      end

      private

      def extract_lines_from(lines, index)
        result = lines[index]
        if result =~ /\{ *$/
          result =~ /^( *)[^ ]/
          leading_spaces = $1
          indent = leading_spaces.size
          begin
            index += 1
            result << lines[index]
          end while lines[index] =~ /^#{leading_spaces} /
        end
        result
      end

      def get_lines(file_name)
        @lines[file_name] ||= open(file_name) { |f| f.readlines }
      end
    end
  end
end
