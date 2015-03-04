require 'vigilem/support/utils'

module Vigilem
module Core::Hooks
  # 
  # utils for the Hooks
  module Utils
    
    include Support::KernelUtils
    
    # 
    # if context of callback is a subclass of this context
    # @param  context
    # @param  callback
    # @return [FalseClass || TrueClass]
    def callback_is_in_subclass?(context, callback)
      get_class(callback.binding.eval('self')) < get_class(context)
    end
    
    extend self
  end
end
end