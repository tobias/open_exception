require File.dirname(__FILE__) + "/open_exception/open_exception"
require File.dirname(__FILE__) + "/open_exception/rails" if defined?(ActionController)

init_message = "** open_extension initialized "

begin
  require 'growl'
  require File.dirname(__FILE__) + "/open_exception/growl_support"
  if Growl.installed?
    init_message << "with growl support"
  else
    init_message << "without growl support (growlnotify binary is not in the path)"
  end
rescue LoadError
  #ignore
end

OpenException.puts init_message
