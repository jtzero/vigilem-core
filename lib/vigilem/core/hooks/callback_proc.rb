require 'vigilem/core/hooks/callback'

module Vigilem::Core::Hooks
  # like a proc but with the added benifit of being called on 
  # in a different context essentially `instance_eval'
  class CallbackProc < Proc
    
    include Callback
    
    # 
    # @param  [Hash] opts for meta use
    # @param  [Proc] block proc to be converted to a CallbackProc
    def initialize(opts={}, &block)
      @options = opts
      super(&block) 
    end
    
    # @return [Hash]
    def options
      @options ||= {}
    end
    
  end
  
end