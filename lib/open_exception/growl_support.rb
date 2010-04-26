module OpenException
  module GrowlSupport
    def self.included(base)
      if !base.instance_methods.include?(:open_without_growl)
        base.send(:alias_method, :open_file_without_growl, :open_file)
        base.send(:alias_method, :open_file, :open_file_with_growl)
      end
    end
    
    protected
    def open_file_with_growl(file, line)
      puts 'growl open file'
      growl_notify(file, line) if File.readable?(file)
      open_file_without_growl(file, line)
    end
    
    def growl_notify(file, line)
      if Growl.installed?
        Growl.notify do |n|
          n.title = 'Open Exception'
          n.message = growl_message(file, line)
        end
      end
    end
    
    def growl_message(file, line)
      msg = "Exception: #{exception.message} at #{exception.backtrace.first}\nOpening #{file}:#{line}"
      msg << " in #{options[:open_with]}" if options[:open_with].is_a?(Symbol)
    end
  end
end

OpenException::ExceptionOpener.send(:include, OpenException::GrowlSupport) 
