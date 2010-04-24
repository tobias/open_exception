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

ActionController::Base.include OpenException::ActionControllerExtensions
