require 'vigilem/support/core_ext'

require 'vigilem/support/obj_space'

require 'vigilem/core/hooks'

require 'vigilem/support/lazy_simple_delegator'

require 'vigilem/core/adapters/adapter'

module Vigilem
module Core
  # 
  class AbstractDevice < Support::LazySimpleDelegator
    
    extend Hooks
    
    include Adapters::Adapter
    
    extend Support::ObjSpace
    
    class << self
      # @param [Array] args
      # @param [Proc] block
      def new(*args, &block)
        ret = obj_register(super(*args, &block))
        run_hook(:after_init, ret)
        ret
      end
      
      # 
      # @param  [Class] base
      # @return 
      def inherited(base)
        super(base)
        hooks.select(&:inheritable?).each do |hook|
          base.instance_eval do
            define_method(hook.name, &hook)
          end
        end
      end
      
    end
    
    Hooks::Hook.new(:after_init).bind(self)
    
    after_init do |dev|
      dev.run_system_checks
    end
    
    # calls all the hooks with options[:type] == :system_check
    # @return [Array<Hook>] the hooks that ran
    def run_system_checks
      self.class.hooks.select {|hook| hook.options[:type] == :system_check }.map do |hook|
        run_hook hook.name
      end
    end
    
    # the Callbacks that passed/ran
    # @return [Array<CallBack>]
    def settings
      hks = self.class.hooks
      passed_hooks = hks.select {|hk| hk.respond_to?(:passed) }
      if _hooks_status_hash_cache_ != (nw_hash = passed_hooks.map(&:status_hash).join)
        @settings = hks.select {|hook| setting?(hook) }.compact
        _hooks_status_hash_cache_ = nw_hash
      end
      @settings
    end
    
    # test whether or not a hook is a setting
    # @param [Hook] hook the hook to test
    # @return [TrueClass || FalseClass]
    def setting?(hook)
      conditional = hook.respond_to?(:passed)
      (not conditional) or (conditional and not hook.passed.empty?)
    end
    
    # if any system_checks pass this device is available
    # @return [TrueClass || FalseClass] whether or not it's available
    def available?
      self.settings.any? {|name, hook| hook.options[:type] == :system_check }
    end
    
    # 
    # @param  obj
    # @return 
    def import(obj)
      self.link = obj
      __setobj__(obj)
    end
    
   private
    attr_accessor :_hooks_status_hash_cache_
  end
end
end
