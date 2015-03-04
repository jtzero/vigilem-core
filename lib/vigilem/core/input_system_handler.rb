require 'forwardable'

require 'vigilem/support/core_ext'

require 'vigilem/core/lockable_pipeline_component'

require 'vigilem/core/adapters/basic_adapter'

require 'vigilem/core/buffer_handler'

require 'vigilem/core/transfer_agent'

module Vigilem
module Core
  # 
  # methods to hand the lower level bindings
  module InputSystemHandler
    
    include BufferHandler
    
    include Adapters::BasicAdapter
    
    include LockablePipelineComponent
    
    extend Support::ObjSpace
    
    extend ActiveSupport::Concern
    
    # 
    # @param  buffer_type
    # @return 
    def initialize_input_system_handler(buffer_type=[])
      ret = initialize_buffer_handler(buffer_type)
      InputSystemHandler.obj_register(self)
      self.class.obj_register(self)
      ret
    end
    
    # 
    # 
    module ClassMethods
      include Support::ObjSpace
      
      include Forwardable
      
      # 
      # 
      def self.extended(base)
        base.extend Support::ObjSpace
      end
    end
    
  end
end
end
