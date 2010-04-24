module OpenException
  
  class << self
    attr_writer :options
    
    def options
      @options ||= { }
    end

    def open(exception, options = { })
      ExceptionOpener.new(exception, options).open
    end
  end

  class ExceptionOpener
    DEFAULT_OPTIONS = {
      :open_with => :emacs,
      :emacs_command => '/usr/bin/emacsclient -n +{line} {file}',
      :textmate_command => '/usr/local/bin/mate -a -d -l {line} {file}',
      :macvim_command => '/usr/local/bin/mvim +{line} {file}'
      # :exclusion_filter => [ExceptionClass, lambda] # any can return/be
      # true to exclude
      # :backtrace_line_filter => [/regex/, lambda] # the first backtrace
      # line that returns true is used
    }

    attr_accessor :options

    def initialize(exception, options = {})
      @exception = exception
      @options = DEFAULT_OPTIONS.merge(OpenException.options).merge(options)
    end

    def open
      if !exclude_exception?
        file_and_line = extract_file_and_line
        open_file(*file_and_line) if file_and_line
      end
    end
    
    protected
    attr_reader :exception
    
    def extract_file_and_line
      if exception.backtrace and
        filter_backtrace(exception.backtrace) =~ /(.*?):(\d*)/
        [$1, $2]
      end
    end

    def filter_backtrace(backtrace)
      if options[:backtrace_line_filter]
        backtrace.find do |line|
          apply_backtrace_filter(options[:backtrace_line_filter], line)
        end
      else
        backtrace.first
      end
    end

    def apply_backtrace_filter(filter, line)
      if filter.respond_to?(:each)
        filter.any? { |f| apply_backtrace_filter(f, line) }
      elsif filter.respond_to?(:call)
        filter.call(line)
      else
        line =~ filter
      end
    end
    
    def exclude_exception?
      if options[:exclusion_filter]
        apply_exclusion_filter(options[:exclusion_filter])
      end
    end

    def apply_exclusion_filter(filter)
      if filter.respond_to?(:each)
        filter.any? { |f| apply_exclusion_filter(f) }
      elsif filter.respond_to?(:call)
        filter.call(exception)
      else
        exception.is_a?(filter)
      end
    end
    
    def open_file(file_name, line_number)
      if File.readable?(file_name)
        cmd = open_command.gsub('{file}', file_name).gsub('{line}', line_number)
        puts cmd
        system(cmd)
      end
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
