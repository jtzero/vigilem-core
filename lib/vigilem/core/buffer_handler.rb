require 'monitor'

require 'thread_safe'

require 'vigilem/core/default_buffer'

module Vigilem
module Core
  # 
  module BufferHandler
    
    attr_accessor :buffers
    
    # @todo  set default buffer type to with somthing like Queue
    # @todo  allow buffer_type argument to be a buffer object 
    #        instead of a delegation to DefaultBuffer
    # @param buffer_type
    def initialize_buffer_handler(buffer_type=[])
      (@buffers ||= ThreadSafe::Hash.new)[:default] = Buffer.new(buffer_type)
    end
    
    # 
    # @return [Monitor]
    def semaphore
      if defined? super
        super
      else
        @semaphore ||= Monitor.new
      end
    end
    
    # 
    # @param  [Symbol] name, defaults to :default
    # @param  type, defaults to nil
    # @return [Buffer]
    def buffer(name=:default, type=nil)
      raise "default buffer not initialised, call #initialize_buffer_handler or #buffer=" unless buffers
      if type
        buffers[name] ||= Buffer.new(type)
      else
        buffers[name]
      end
    end
    
    alias_method :inbox, :buffer
    
    # needed for peek
    # @param  [Integer] len
    # @param  [Symbol] buffer_name
    # @param  [Proc] block
    # @return 
    def buffered(len, buffer_name=:default, opts={}, &block)
      semaphore.synchronize {
        ret, still_to_get = buffer(buffer_name, opts[:type]).offset(len)
        if still_to_get > 0
          src_data = Support::Utils.send_all_or_no_args(block, still_to_get)
          called_for = src_data.slice!(0, still_to_get)
          ret.concat(called_for)
        end
        ret
      }
    end
    
    # buffers the block, by taking len from the buffer
    # and calling the block for the remaining
    # @param  [Integer] len
    # @param  [Symbol] buffer_name
    # @param  [Proc] block
    # @return 
    def buffered!(len=nil, buffer_name=:default, opts={}, &block)
      semaphore.synchronize {
        ret, still_to_get = buffer(buffer_name, opts[:type]).offset!(len)
        if still_to_get > 0
          src_data = Support::Utils.send_all_or_no_args(block, still_to_get)
          called_for = src_data.slice!(0, still_to_get)
          ret.concat(called_for)
          buffer(buffer_name).concat(src_data)
        end
        ret
      }
    end
    
   private 
    
    # 
    # @param  set_val
    # @return 
    def buffer=(set_val)
      @buffers[:default] = set_val
    end
    
    alias_method :inbox=, :buffer=
  end
end
end
