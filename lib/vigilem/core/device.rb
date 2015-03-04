require 'vigilem/core/abstract_device'

require 'vigilem/core/hooks'

require 'vigilem/core/system'

module Vigilem
module Core
  # 
  # hooks for loading the pipeline
  # errors when no :system_check has passed
  # @todo more configurable facade so not all methods from
  #       underlying object get through
  class Device < AbstractDevice
    
    # 
    # @param  [Array] args
    # @param  [Proc] config
    # @return 
    def self.new(*args, &config)
      if block_given?
        (ret = Class.new(self)).instance_eval(&config)
        ret
      else
        super(*args)
      end
    end
    
    Hooks::ConditionalHook.new(:on_os, :type => :system_check) do
      condition {|name_or_regex| System.check[:os].call(name_or_regex) }
    end.bind(self)
    
    Hooks::ConditionalHook.new(:on_input_system, :type => :system_check) do
      condition {|name_or_regex| System.check[:input_system].call(name_or_regex) }
    end.bind(self)
    
    after_init do |dev|
      raise 'Device not compatible on this system' unless dev.available?
    end
    
  end
end
end