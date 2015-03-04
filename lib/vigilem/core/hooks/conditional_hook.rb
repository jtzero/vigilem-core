require 'vigilem/core/hooks'

module Vigilem::Core::Hooks
  # 
  # 
  class ConditionalHook < Hook
    
    # enumerate over the callbacks
    # @param  [Array] args
    # @param  [Proc] block
    # @return 
    def enumerate(args={}, &block)
      passed, failed = [], []
      hook = self
      super do |callback|
        if hook.condition.call(*callback.options[:condition_args])
          hook.passed << callback
          callback.evaluate(args[:context], *args[:args], &args[:block])
        else
          hook.failed << callback
        end
      end
    end
    
    # 
    # @param  [Proc] condition 
    # @return 
    def condition(&condition)
      condition ? @condition = condition : @condition ||= lambda { true }
    end
      
    # 
    # @return [Array] 
    def passed
      @passed ||= []
    end
    
    # 
    # @return [Array] 
    def failed
      @failed ||= []
    end
    
    # 
    # @return [Array<Array,Array>] 
    def status_hash
      [[passed, failed]].hash
    end
    
    # 
    # @return 
    def default_body
      @default_body ||= begin
          hook = self
          lambda do |*args, &block|
            hook.callbacks << CallbackProc.new({:condition_args => args }, &block)
          end
        end
    end
    
  end
end