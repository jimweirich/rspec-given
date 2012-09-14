require 'spec_helper'

module RSpec
  module Given

    describe LineCache do

      class FauxFileCache
        def initialize(lines)
          @lines = lines.split(/\n/).map { |ln| ln + "\n" }
        end
        def get(file_name)
          @lines
        end
      end

      Given(:file) { "MIT-LICENSE" }
      Given(:line) { 2 }
      Given(:file_cache) { FauxFileCache.new(input) }
      Given(:cache) { LineCache.new(file_cache) }

      When(:result) { cache.line(file, line) }

      describe "reading a line" do
        Given(:input) {
          "  Now is the time\n" +
          "  for all good men\n" +
          "  to come to the aid\n" +
          "  of their fellowmen\n"
        }
        Given(:expected_line) { "  for all good men\n" }
        Then { result.should == expected_line }
      end

      context "when the line doesn't exist" do
        Given(:input) { "" }
        Then { result.should be_nil }
      end

      context "when the line has leading and trailing white space" do
        Given(:input) {
          "  Then { y } \n" +
          "  Then { x }\n"
        }
        Then { result.should == "  Then { x }\n" }
      end

      context "when the Then is split over several lines with {}" do
        Given(:input) {
          "describe 'foobar' do\n" +
          "  Then {\n" +
          "    x\n" +
          "  }\n" +
          "end\n"
        }
        Then { result.should == "  Then {\n    x\n  }\n" }
      end

      context "when the Then is split over several lines with do/end" do
        Given(:input) {
          "describe 'foobar' do\n" +
          "  Then do\n" +
          "    x\n" +
          "  end\n" +
          "end\n"
        }
        Then { result.should == "  Then do\n    x\n  end\n" }
      end
    end
  end
end
