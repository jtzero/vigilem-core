require 'forwardable'

require 'thread'

require 'active_support/concern'

require 'vigilem/support/core_ext'

require 'vigilem/core/lockable_pipeline_component'

require 'vigilem/core/adapters/basic_adapter'

module Vigilem
module Core
module Adapters
  # 
  module Adapter
    
    extend ActiveSupport::Concern
    
    include BasicAdapter
    
    include LockablePipelineComponent
    
    # 
    # @param  link
    def initialize_adapter(lnk=nil)
      initialize_basic_adapter(lnk)
    end
    
    # 
    # 
    module ClassMethods
      include Forwardable
    end
    
    # 
    # @param  src
    # @param  [Hash] opts, future use
    # @return self
    def attach(src, opts={})
      self.link = src
      self
    end
    
    # 
    # @param  src
    # @param  [Hash] opts, future use
    # @return link
    def affix(src, opts={})
      self.link = src
    end
    
  end
end
end
end
