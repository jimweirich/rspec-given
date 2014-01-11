require 'spec_helper'

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
      Then { expect(result).to eq(expected_line) }
    end

    context "when the line doesn't exist" do
      Given(:input) { "" }
      Then { expect(result).to be_nil }
    end

    context "when the line has leading and trailing white space" do
      Given(:input) {
        "  Then { y } \n" +
        "  Then { x }\n"
      }
      Then { expect(result).to eq("  Then { x }\n") }
    end

    context "when the Then is split over several lines with {}" do
      Given(:input) {
        "describe 'foobar' do\n" +
        "  Then {\n" +
        "    x\n" +
        "  }\n" +
        "end\n"
      }
      Then { expect(result).to eq("  Then {\n    x\n  }\n") }
    end

    context "when the Then is has blank lines" do
      Given(:input) {
        "describe 'foobar' do\n" +
        "  Then {\n\n" +
        "    x\n" +
        "  }\n" +
        "end\n"
      }
      Then { expect(result).to eq("  Then {\n\n    x\n  }\n") }
    end

    context "when the Then is split over several lines with do/end" do
      Given(:input) {
        "describe 'foobar' do\n" +
        "  Then do\n" +
        "    x\n" +
        "  end\n" +
        "end\n"
      }
      Then { expect(result).to eq("  Then do\n    x\n  end\n") }
    end

    context "when the Then is oddly formatted" do
      Given(:input) {
        "describe 'foobar' do\n" +
        "  Then { result == ['a',\n" +
        "            'a'] }\n" +
        "end\n"
      }
      Then { expect(result).to eq("  Then { result == ['a',\n            'a'] }\n") }
    end

    describe "converting to a string" do
      Given(:input) { "" }
      Then { expect(extractor.to_s).to match(/line *extractor/i) }
    end
  end
end
