require 'spec_helper'

module RSpec
  module Given

    describe LineCache do
      Given(:file) { "MIT-LICENSE" }
      Given(:line) { 3 }
      Given(:cache) { LineCache.new }

      Given(:expected_line) { "Permission is hereby granted, free of charge, to any person obtaining\n" }

      When(:result) { cache.line(file, line) }

      describe "reading a line" do
        Then { result.should == expected_line }
      end

      describe "when the file is read twice" do
        Given { flexmock(cache).should_receive(:open).pass_thru }

        When(:second_result) { cache.line(file, line) }

        Then { second_result.should == expected_line }
        Then { cache.should have_received(:open).once }
      end

      context "when the line doesn't exist" do
        Given { flexmock(cache).should_receive(:open).and_return([])}
        Then { result.should be_nil }
      end

      context "when the line has leading and trailing white space" do
        Given { flexmock(cache).should_receive(:open).and_return(["\n", "\n", "  Then { x }\n"])}
        Then { result.should == "  Then { x }\n" }
      end

      context "when the Then is split over several lines" do
        Given { flexmock(cache).should_receive(:open).and_return(["\n", "\n", "  Then {\n", "    x\n", "  }\n", "\n"])}
        Then { result.should == "  Then {\n    x\n  }\n" }
      end

    end

  end
end
