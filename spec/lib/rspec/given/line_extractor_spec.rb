require 'spec_helper'

module RSpec
  module Given

    describe LineExtractor do

      class FauxFileCache
        def initialize(lines)
          @lines = lines.split(/\n/).map { |ln| ln + "\n" }
        end
        def get(file_name)
          @lines
        end
      end

      Given(:line) { 2 }
      Given(:file_cache) { FauxFileCache.new(input) }
      Given(:extractor) { LineExtractor.new(file_cache) }

      When(:result) { extractor.line("FILENAME", line) }

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

      context "when the Then is has blank lines" do
        Given(:input) {
          "describe 'foobar' do\n" +
          "  Then {\n\n" +
          "    x\n" +
          "  }\n" +
          "end\n"
        }
        Then { result.should == "  Then {\n\n    x\n  }\n" }
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

      describe "converting to a string" do
        Given(:input) { "" }
        Then { extractor.to_s.should =~ /line *extractor/i }
      end
    end
  end
end
