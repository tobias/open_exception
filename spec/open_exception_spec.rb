require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'tempfile'

describe "OpenException" do
  describe "parsing an exception" do
    it "should extract the file and line number" do
      @opener = opener(stub_exception)
      @opener.send(:extract_file_and_line)
      @opener.send(:file_name).should == '/some/file.rb'
      @opener.send(:line_number).should == '1'
    end

    it "should filter with a regex" do
      @opener = opener(stub_exception,
                       :backtrace_line_filters => [/other_file/])
      @opener.send(:extract_file_and_line)
      @opener.send(:file_name).should == "/some/other_file.rb"
      @opener.send(:line_number).should == '22'
    end

    it "should filter with a lambda" do
      @opener = opener(stub_exception,
                       :backtrace_line_filters => [lambda { |line| line =~ /other_file/ }])
      @opener.send(:extract_file_and_line)
      @opener.send(:file_name).should == "/some/other_file.rb"
      @opener.send(:line_number).should == '22'
    end

    it "should filter with an array of filters" do
      @opener = opener(stub_exception,
                       :backtrace_line_filters => [/not gonna match/,
                                                   /other_file/])
      @opener.send(:extract_file_and_line)
      @opener.send(:file_name).should == "/some/other_file.rb"
      @opener.send(:line_number).should == '22'
    end
  end

  describe "opening an exception" do
    it "should try to open the file" do
      @opener = opener(stub_exception)
      @opener.should_receive(:open_file)
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
        @opener = opener(Exception.new, :exclusion_filters => [Exception])
        @opener.should_not_receive(:extract_file_and_line)
        @opener.open
      end

      it "should exclude based on a lambda" do
        @opener = opener(Exception.new, :exclusion_filters => [lambda { |ex| true }])
        @opener.should_not_receive(:extract_file_and_line)
        @opener.open
      end

      it "should exclude based on an array of filters" do
        @opener = opener(Exception.new, :exclusion_filters => [StandardError, Exception])
        @opener.should_not_receive(:extract_file_and_line)
        @opener.open
      end
    end
    
    describe "open_file" do
      it "should not try to open a file that does not exist" do
        @opener = opener(nil)
        @opener.should_not_receive(:system)
        @opener.file_name = '/a/nonexistent/file'
        @opener.send(:open_file)
      end

      it "should write out the stack to a file if the open_command contains {stackfile}" do
        File.stub!(:readable?).and_return(true)
        @opener = opener(stub_exception)
        @opener.stub!(:open_command).and_return('{stackfile}')
        Tempfile.should_receive(:open)
        @opener.file_name = '/a/file'
        @opener.line_number = '2'
        @opener.stub!(:system)
        @opener.send(:open_file)
        
      end
    end
  end
end

class OpenException::ExceptionOpener
  attr_writer :file_name, :line_number
end

def opener(ex, options = { })
  OpenException::ExceptionOpener.new(ex, options)
end


