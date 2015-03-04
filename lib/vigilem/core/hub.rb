require 'vigilem/support/obj_space'

module Vigilem
module Core
  # copies events or messages from the system to all the 
  # attached buffers except the link, much like a network hub
  class Hub
    
    attr_reader :buffers, :group_id
    
    # @param group
    def initialize(group)
      @group_id = group
      @buffers = []
    end
    
    # 
    # @param  [EventBuffer] buffer that will receive events from the hub
    # @return self is expected like array
    def add_buffer(buffer)
      @buffers << buffer
      self
    end
    
    alias_method :<<, :add_buffer
    
    # 
    # @param  [Array] msgs the messages to push out
    # @return [Array] the buffers that got updated
    def demux(buff, *msgs)
      buffers.except(buff).select {|buffer| buffer.concat(msgs) unless msgs.empty? } 
    end
    
    extend Support::ObjSpace
    
    class << self
      
      # 
      # finds a hub based on a group identifier, if no Hub is found
      # a new one is returned
      # @param  link the link registered for a hub
      # @return [Hub] the hub for passed in link
      def aquire(grp_id)
        all.find {|hub| hub.group_id == grp_id } || obj_register(new(grp_id))
      end
      
    end
  end
end
end
