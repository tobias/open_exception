require File.dirname(__FILE__) + "/open_exception/open_exception"
require File.dirname(__FILE__) + "/open_exception/rails" if defined?(ActionController)

init_message = "** open_extension initialized "

begin
  require 'growl'
  require File.dirname(__FILE__) + "/open_exception/growl_support"
  init_message << "with growl support"
rescue LoadError
  #ignore
end

puts init_message
