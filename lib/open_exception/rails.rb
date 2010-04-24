module OpenException
  module ActionControllerExtensions
    def self.included(base)
      base.send(:alias_method,
                :rescue_action_locally_without_open_exception,
                :rescue_action_locally)
      base.send(:alias_method,
                :rescue_action_locally,
                :rescue_action_locally_with_open_exception)
    end
    
    def rescue_action_locally_with_open_exception(exception)
      OpenException.open(exception)
      rescue_action_locally_without_open_exception(exception)
    end
  end
end

if !ActionController::Base.ancestors.include?(OpenException::ActionControllerExtensions)
  ActionController::Base.send(:include, OpenException::ActionControllerExtensions)
  OpenException.options[:backtrace_line_filter] = %r{#{Rails.root}/(app|lib)}
end
