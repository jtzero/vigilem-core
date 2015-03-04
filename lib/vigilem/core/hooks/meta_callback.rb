require 'delegate'

module Vigilem::Core::Hooks
  # @todo better name?
  # CallbackProc that remebers if it has been ran/evaluated/called
  class MetaCallback < DelegateClass(CallbackProc)
    
    # 
    # @param  [CallbackProc] cbp a CallbackProc 
    #                                to be converted to a MetaCallback
    # @param  [Proc] block a Proc to be converted to a MetaCallback
    def initialize(cbp=nil, &block)
      self.ran = false
      super(cbp || CallbackProc.new(&block))
    end
    
    # 
    # @param  context the context which to evaluate under
    # @param  [Array] args arguments to be passed to the proc
    # @param  [Proc] block Proc to be passed to the proc
    # @return the result of the 
    def evaluate(context, *args, &block)
      self.ran = true
      super(context, *args, &block)
    end
    
    alias_method :[], :evaluate
    
    # 
    # @param  [Array] args arguments to be passed to the proc
    # @param  [Proc] block Proc to be passed to the proc
    # @return the result of the proc
    def call(*args, &block)
      self.ran = true
      super(*args, &block)
    end
    
    # whether or not this proc ran
    # @return [TrueClass || FalseClass]
    def ran?
      @ran
    end
    
   private
    
    # 
    # @param  [TrueClass || FalseClass] status
    # @return @ran
    def ran=(status)
      @ran = status
    end
  end
end
