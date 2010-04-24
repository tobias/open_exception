require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "OpenException" do
  describe "parsing an exception" do
    it "should extract the file and line number" do
      opener(stub_exception).send(:extract_file_and_line).should == ['/some/file.rb',
                                                                     '1']
    end

    it "should filter with a regex" do
      @opener = opener(stub_exception,
                       :backtrace_line_filter => /other_file/)
      @opener.send(:extract_file_and_line).should == ["/some/other_file.rb", '22']
    end

    it "should filter with a lambda" do
      @opener = opener(stub_exception,
                       :backtrace_line_filter => lambda { |line| line =~ /other_file/ })
      @opener.send(:extract_file_and_line).should == ["/some/other_file.rb", '22']
    end

    it "should filter with an array of filters" do
      @opener = opener(stub_exception,
                       :backtrace_line_filter => [/not gonna match/,
                                                  /other_file/])
      @opener.send(:extract_file_and_line).should == ["/some/other_file.rb", '22']
    end
  end

  describe "opening an exception" do
    it "should pass the exception args to open_file" do
      @opener = opener(stub_exception)
      @opener.should_receive(:open_file).with('/some/file.rb',
                                              '1')
      @opener.open
    end

    it "should not try to open if no backtrace exists" do
      @opener = opener(Exception.new)
      @opener.should_not_receive(:open_file)
      @opener.open
    end
    
    describe "excluding exceptions" do
      it "should not try to open the exception if it should be excluded" do
        @opener = opener(Exception.new)
        @opener.should_receive(:exclude_exception?).and_return(true)
        @opener.should_not_receive(:extract_file_and_line)
        @opener.open
      end

      it "should exclude based on exception class" do
        @opener = opener(Exception.new, :exclusion_filter => Exception)
        @opener.should_not_receive(:extract_file_and_line)
        @opener.open
      end

      it "should exclude based on a lambda" do
        @opener = opener(Exception.new, :exclusion_filter => lambda { |ex| true })
        @opener.should_not_receive(:extract_file_and_line)
        @opener.open
      end

      it "should exclude based on an array of filters" do
        @opener = opener(Exception.new, :exclusion_filter => [StandardError, Exception])
        @opener.should_not_receive(:extract_file_and_line)
        @opener.open
      end
    end
    
    describe "open_file" do
      it "should not try to open a file that does not exist" do
        @opener = opener(nil)
        @opener.should_not_receive(:system)
        @opener.send(:open_file, '/a/nonexistent/file', '0')
      end
    end
  end
end

def opener(ex, options = { })
  OpenException::ExceptionOpener.new(ex, options)
end


