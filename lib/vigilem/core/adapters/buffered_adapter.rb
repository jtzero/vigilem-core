require 'vigilem/core/adapters/adapter'

require 'vigilem/core/buffer_handler'

module Vigilem
module Core
module Adapters
  # 
  module BufferedAdapter
    
    include Vigilem::Core::Adapters::Adapter
    
    include BufferHandler
    
    extend ActiveSupport::Concern
    
    #
    # @param  lnk
    # @param  buffer_type
    def initialize_buffered(lnk=nil, buffer_type=[])
      initialize_adapter(lnk)
      initialize_buffer_handler(buffer_type)
    end
    
  end
end
end
end
