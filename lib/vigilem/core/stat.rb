require 'vigilem/support/core_ext'

require 'vigilem/support/obj_space'

require 'vigilem/core/system'

require 'rubygems/dependency_installer'

module Vigilem
module Core
  # 
  # Stat(us) of the input_system and the handler 
  # gem associated with it
  class Stat
    attr_reader :platform_masks, :gem_name, :input_system_name
    
    attr_accessor :api_check
    
    private :api_check, :api_check=
    
    # @fixme  duplicates in ::all
    # @param  [String] gem_name
    # @param  [Hash] opts
    # @param  [Proc] api_check
    # @return 
    def self.new(*args, &block)
      obj_register(super(*args, &block))
    end
    
    # 
    # @param  [Array] args
    # @param  [Proc] block
    # @return [TrueClass || FalseClass]
    def api_check?(*args, &block)
      !!api_check.call(*args, &block)
    end
    
    # 
    # @param  [String] input_system, the descriptive name of the input_system
    # @param  [String] gemname, the gem name of the handler to install
    # @param  [Hash] opts
    # @option opts [Array<Regexp || Symbol>] :platforms
    # @option opts :requirement, defaults to Gem::Requirement.default
    # @param  [Proc] api_check
    # @return 
    def initialize(input_system, gemname, opts={}, &api_check)
      @input_system_name = input_system
      @gem_name = gemname
      @gem_requirement = opts[:requirement] ||= Gem::Requirement.default
      
      @platform_masks = [*opts[:platforms] || /.+/].map do |plats| 
        if plats.is_a?(Symbol)
          System::SYSTEM_NAME_MASKS[plats]
        elsif plats.is_a?(Regexp)
          plats
        else
          raise NotImplementedError, "UnSupported type #{plats.class}:#{plats}"
        end
      end
      @api_check = api_check
    end
    
    # 
    # 
    def gem_requirement
      @gem_requirement ||= Gem::Requirement.default
    end
    
    # whether or not this input_system is availble on given os
    # @param  [String || Regexp] os
    # @return [TrueClass || FalseClass]
    def available_on?(os)
      System.check[:os][Regexp.union(platform_masks), os]
    end
    
    alias_method :is_available_on?, :available_on?
    
    # 
    # @param  version_requirement, optional
    # @return 
    def install(version_requirement=nil)
      @installed = installer.install(gem_name, *version_requirement)
    end
    
    # 
    # @return [TrueClass || FalseCLass]
    def installed?
      if @installed.nil?
        @installed = Gem::Specification.find_all_by_name(gem_name, *gem_requirement).any?
      else
        @installed
      end
    end
    
    #   
    # whether or not this input_system is avaialble on this system
    # @return [TrueClass || FalseClass]
    def available?
      available_on?(System.os) and api_check?
    end
    
    extend Support::ObjSpace
    
    class << self
      # 
      # @return [Array<Stat>]
      def all_available
        all.select(&:available?)
      end
      
    end
   private
    
    # 
    # @return [Gem::DependencyInstaller]
    def installer
      @installer ||= Gem::DependencyInstaller.new
    end
  end
end
end
