require 'spec_helper'

module RSpec
  module Given

    DESCRIBE_LINE = __LINE__
    describe FileCache do
      Given(:file_name) { __FILE__ }
      Given(:cache) { FileCache.new }

      When(:result) { cache.get(file_name) }

      context "when reading the file" do
        Then { result[DESCRIBE_LINE].should =~ /describe FileCache do/ }
        Then { result.size.should == MAX_LINE }
      end

      context "when getting the same file twice" do
        Given { cache.should_receive(:read_lines).once.and_return(["A"]) }
        When(:result2) { cache.get(file_name) }
        Then { result.should == ["A"] }
        Then { result2.should == ["A"] }
      end
    end
  end
end

MAX_LINE = __LINE__
