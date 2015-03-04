require 'vigilem/support/core_ext'

module Vigilem
module Core
module Hooks
  # 
  module Inheritable
    
    # 
    # @param  base
    def inherited(base)
      base.extend Inheritable
    end
    
    # 
    # @return [Array]
    def hooks
      @hooks ||= (self.superclass.respond(:hooks) || []).select(&:inheritable?)
    end
    
  end
end
end
end