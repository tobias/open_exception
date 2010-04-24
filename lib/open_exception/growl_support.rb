module OpenException
  module GrowlSupport
    protected
    def open_file(file, line)
      growl_notify(file_line) if File.readable?(file)
      super
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
      msg = "Opening #{file}:#{line}"
      msg << " in #{options[:open_with]}" if options[:open_with].is_a?(Symbol)
    end
  end
end

OpenException::ExceptionOpener.send(:include, OpenException::GrowlSupport)
