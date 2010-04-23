require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

require File.expand_path(File.dirname(__FILE__) + '/../test_data/raiser')

describe "OpenException" do
  before(:all) do
    @opener = OpenException::ExceptionOpener.new({ })
    @raiser = Raiser.new
  end
  
  describe "parsing an exception" do
    it "should extract the file and line number" do
      raise_now do |ex|
        @opener.send(:extract_file_and_line, ex).should == [@raiser.file, "5"]
      end
    end

    describe "opening an exception" do
      it "should pass the exception args to open_file" do
        @opener.should_receive(:open_file).with(@raiser.file, "5")
        raise_now do |ex|
          @opener.open(ex)
        end
      end
    end
  end

end

def raise_now
  @raiser.raise_now
rescue Exception => ex
  yield ex
end
