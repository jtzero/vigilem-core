require 'vigilem/core/hooks/inheritable'

module Vigilem::Core
  # 
  # extend this
  module Hooks
    
    include Inheritable
    
    # 
    # @param base
    def self.extended(base)
      # instance_level
      base.send(:define_method, :run_hook) do |hook_name, *args, &block|
        self.class.hooks.find {|hook| hook.name == hook_name }.run(self, *args, &block)
      end
    end
    
    # 
    # class level
    # finds a hook by that name and runs it
    # @param  hook_name the hook to find
    # @param  [Array] args arguments to be passed to the hook 
    # @param  [Proc] block Proc to be passed to the hook
    # @return [Hook]
    def run_hook(hook_name, *args, &block)
      hooks.find {|hook| hook.name == hook_name }.run(self, *args, &block)
    end
    
  end
end

Vigilem::Core::HooksBase = Vigilem::Core::Hooks

require 'vigilem/core/hooks/hook'
require 'vigilem/core/hooks/conditional_hook'