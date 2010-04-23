module OpenException
  
  class << self

    attr_writer :options
    
    def options
      @options ||= { }
    end

    def open(exception, options = { })
      ExceptionOpener.new(options).open(exception)
    end

  end

  class ExceptionOpener
    DEFAULT_OPTIONS = {
      :open_with => :emacs,
      :emacs_command => '/usr/bin/emacsclient -n +{line} {file}',
      :textmate_command => '/usr/local/bin/mate -a -d -l {line} {file}',
      :macvim_command => '/usr/local/bin/mvim +{line} {file}'
    }

    attr_accessor :options
    
    def initialize(options)
      self.options = DEFAULT_OPTIONS.merge(OpenException.options).merge(options)
    end

    def open(exception)
        open_file(*extract_file_and_line(exception))
    end
    
    protected
    def extract_file_and_line(exception)
      if exception.backtrace.first =~ /(.*?):(\d*)/
        [$1, $2]
      end
    end
    
    def unwind_exception(exception)
      
    end

    def open_file(file_name, line_number)
      cmd = open_command.gsub('{file}', file_name).gsub('{line}', line_number)
      puts cmd
      system(cmd)
    end

    def open_command
      if options[:open_with].is_a?(Symbol)
        options[:"#{options[:open_with]}_command"]
      else
        options[:open_with]
      end
    end
  end

end
