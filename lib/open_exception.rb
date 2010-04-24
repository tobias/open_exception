require File.dirname(__FILE__) + "/open_exception/open_exception"
require File.dirname(__FILE__) + "/open_exception/rails" if defined?(ActionController)

begin
  require 'growl'
  require File.dirname(__FILE__) + "/open_exception/growl_support"
rescue LoadError
  #ignore
end
