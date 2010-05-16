module OpenException
  module GrowlSupport
    def self.included(base)
      if !base.instance_methods.include?(:open_without_growl)
        base.send(:alias_method, :open_file_without_growl, :open_file)
        base.send(:alias_method, :open_file, :open_file_with_growl)
      end
    end
    
    protected
    def open_file_with_growl
      growl_notify if File.readable?(file_name)
      open_file_without_growl
    end
    
    def growl_notify
      if Growl.installed?
        Growl.notify do |n|
          n.title = 'Open Exception'
          n.message = growl_message
        end
      end
    end
    
    def growl_message
      msg = "Exception: #{exception.message} at #{exception.backtrace.first}\nOpening #{file_name}:#{line_number}"
    end
  end
end

OpenException::ExceptionOpener.send(:include, OpenException::GrowlSupport) 
