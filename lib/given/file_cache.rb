
module Given
  class FileCache
    def initialize
      @lines = {}
    end

    def get(file_name)
      @lines[file_name] ||= read_lines(file_name)
    end

    private

    def read_lines(file_name)
      open(file_name) { |f| f.readlines }
    end
  end
end
