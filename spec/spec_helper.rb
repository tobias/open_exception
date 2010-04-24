$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'open_exception'
require 'spec'
require 'spec/autorun'
require 'rubygems'
require 'ap'

Spec::Runner.configure do |config|
  
end

def stub_exception
  ex = mock('exception')
  ex.stub!(:backtrace).and_return([
                                   "/some/file.rb:1:in 'level_one'",
                                   "/some/other_file.rb:22:in 'level_two'",
                                   "/some/a_third_file.rb:333:in 'level_three'"
                                  ])
  ex
end

