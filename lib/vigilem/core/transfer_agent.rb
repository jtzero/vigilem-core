
require 'forwardable'

require 'vigilem/support/core_ext'

require 'vigilem/support/obj_space'

require 'vigilem/core/multiplexer'

require 'vigilem/core/demultiplexer'

module Vigilem
module Core
  # 
  # facade for demultiplexer <-> multiplexer coupling
  class TransferAgent
    
    extend Forwardable
    
    attr_reader :multiplexer, :demultiplexer
    
    def_delegators :demultiplexer, :add_observer, :add_observers, :outputs
    
    def_delegator :multiplexer, :add_inputs
    
    # 
    # 
    def self.new(*args)
      obj_register(super(*args))
    end

    # sets the input on demultiplexer to the ouput of multiplexer
    # if both are nil it sets it to an Array
    # @param  [#input=, #demux]
    # @param  [#out, #mux]
    def initialize(demuxer, muxer)
      @demultiplexer, @multiplexer = demuxer, muxer
      if (junction = (din = demultiplexer.input) || (mout = multiplexer.out)).nil? or not mout.equal?(din)
        @demultiplexer.input = @multiplexer.out = (junction || [])
      end
    end
    
    # checks 
    # @param  [Integer] num_of_events, defaults to 1
    # @return [NilClass]
    def relay(num_of_events=1)
      multiplexer.mux(num_of_events)
      demultiplexer.demux(num_of_events)
      nil
    end
    
    extend Support::ObjSpace
    
    class << self
      
      # 
      # @param  [Module]
      # @return 
      def inherited(base)
        base.extend Support::ObjSpace
      end
      
    end
    
  end
end
end
