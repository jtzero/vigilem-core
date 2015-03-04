require 'delegate'

require 'vigilem/core/buffer'

module Vigilem
module Core
  # 
  class DefaultBuffer < ::SimpleDelegator
    include Buffer
    
    # 
    # @param [#slice!] type
    def initialize(type=[])
      super(type)
    end
    
    # like new except type is not optional
    # and passes through an object that is 
    # already of self type
    # @param  type
    # @return [DefaultBuffer]
    def self.wrap(type)
      if type.is_a? self      
        type
      else
        new(type)
      end
    end
    
    # 
    # @param  other_obj
    # @return [TrueClass || FalseClass]
    def ==(other_obj)
      super(other_obj) || 
        __getobj__ == other_obj.respond.__getobj__
    end
    
    # 
    # @return [String]
    def inspect
      "#<#{self.class}:0x#{object_id} #{super}>"
    end
  end
end
end
