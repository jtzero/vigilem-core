module Vigilem::Core::Hooks
  # core interface for a callback
  # @abstract
  module Callback
    
    # 
    attr_accessor :options, :result
    
    # @see    CallbackProc
    # @param  [Hash] opts
    # @param  [Proc] block
    # @return [CallbackProc]
    def self.new(opts={}, &block)
      CallbackProc.new(opts, &block)
    end
    
    # evaluates the Callback in the specified context
    # @param  context
    # @param  [Array] args 
    # @param  [Proc] block
    # @return [Array]
    def evaluate(context, *args, &block)
      self.result = if block
          context.define_singleton_method(:__callback__, &self)
          ret = context.send :__callback__, *args, &block
          context.class_eval { send :remove_method, :__callback__ }
          ret
        else
          context.instance_exec(*args, &self)
        end
    end
    
    alias_method :[], :evaluate
    
    # calls super if defined? otherwise calls to_proc.call(*args, &block)
    # @see    Proc#call
    # @param  [Array] args
    # @param  [Proc] block
    # @return result 
    def call(*args, &block)
      self.result = defined?(super) ? super(*args, &block) : to_proc.call(*args, &block)
    end
    
    # calls super, otherwise it's just a helper
    # @raise  [RuntimeError]
    # @return [Proc]; this object as a Proc
    def to_proc
      defined?(super) ? super : raise('must overload to_proc')
    end
    
    # calls super, otherwise it's just a helpful reminder
    # @raise  [RuntimeError]
    # @return [Proc]; this object as a Proc
    def binding
      defined?(super) ? super : raise('must overload binding')
    end
    
   private
    
    # @param  res
    # @return res
    def result=(res)
      @result = res
    end
  end
end
