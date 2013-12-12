require 'spec_helper'

module Given

  DESCRIBE_LINE = __LINE__
  describe FileCache do
    Given(:file_name) { __FILE__ }
    Given(:cache) { FileCache.new }

    When(:result) { cache.get(file_name) }

    context "when reading the file" do
      Then { expect(result[DESCRIBE_LINE]).to match(/describe FileCache do/) }
      Then { expect(result.size).to eq MAX_LINE }
    end

    context "when getting the same file twice" do
      Given { expect(cache).to receive(:read_lines).once.and_return(["A"]) }
      When(:result2) { cache.get(file_name) }
      Then { expect(result).to eq ["A"] }
      Then { expect(result2).to eq ["A"] }
    end
  end
end

MAX_LINE = __LINE__
