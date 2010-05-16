require 'tempfile'

module OpenException

  EDITOR_COMMANDS = {
    :emacs => '/usr/bin/emacsclient -n +{line} {file}',
    :emacs_with_stack => '/usr/bin/emacsclient -e \'(open-stack-and-file "{stackfile}" "{file}" {line})\'',
    :textmate => '/usr/local/bin/mate -a -d -l {line} {file}',
    :macvim => '/usr/local/bin/mvim +{line} {file}'
  }
  
  DEFAULT_OPTIONS = {
    :open_with => :emacs,
    :exclusion_filters => [], #[ExceptionClass, lambda] # any can return/be true to exclude
    :backtrace_line_filters => [] #[/regex/, lambda] # the first backtrace line that returns true is used
  }

  class << self
    def options
      @options ||= DEFAULT_OPTIONS.clone
    end

    def configure
      yield Configurator.new(options)
    end

    def open(exception, options = { })
      ExceptionOpener.new(exception, options).open
    end

    def puts(msg)
      defined?(Rails) ? Rails.logger.info(msg) : super
    end
  end

  class ExceptionOpener

    attr_accessor :options

    def initialize(exception, options = {})
      @exception = exception
      @options = OpenException.options.merge(options)
    end

    def open
      extract_file_and_line && open_file unless exclude_exception?
    end

    protected
    attr_reader :exception, :file_name, :line_number

    def extract_file_and_line
      if exception.backtrace and
          filter_backtrace(exception.backtrace) =~ /(.*?):(\d*)/
        @file_name = $1
        @line_number = $2
      end
    end

    def filter_backtrace(backtrace)
      if !options[:backtrace_line_filters].empty?
        backtrace.find do |line|
          apply_backtrace_filter(options[:backtrace_line_filters], line)
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
      if !options[:exclusion_filters].empty?
        apply_exclusion_filter(options[:exclusion_filters])
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

    def open_file
      if File.readable?(file_name)
        cmd = open_command.gsub('{file}', file_name).gsub('{line}', line_number)
        if cmd =~ /\{stackfile\}/
          Tempfile.open('open_exception-stack') do |f|
            f << exception.message
            f << "\n"
            f << exception.backtrace.join("\n")
            cmd.gsub!('{stackfile}', f.path)
          end
        end
        system(cmd)
      end
    end

    def open_command
      if options[:open_with].is_a?(Symbol)
        EDITOR_COMMANDS[options[:open_with]]  
      else
        options[:open_with]
      end
    end
  end
  
  class Configurator
    def initialize(options)
      @options = options
    end

    def method_missing(method, arg = nil)
      if method.to_s =~ /(.*?)=/
        @options[$1.to_sym] = arg
      else
        @options[method]
      end
    end
  end
end
