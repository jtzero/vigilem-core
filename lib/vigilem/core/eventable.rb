module Vigilem
module Core
  # @abstract 
  # contract the ensures some common event methods are available
  module Eventable
    # @abstract need to override read_many_nonblock, optional synchronize
    module ReadMethods
      
      # @abstract 
      # @param  [Integer] max_number_of_events=1
      # @return [Array]
      def read_many_nonblock(max_number_of_events=1)
        raise NotImplemented, 'read_many_nonblock not overridden'
      end
      
      # 
      # passes to super if exists, otherwise yield makes
      # overwriting it optional
      def synchronize
        if defined?(super)
          super
        else
          yield
        end
      end
      
      # reads until a specified number of events have been read
      # @param  [Integer] number_of_events=1
      # @return [Array]
      def read_many(number_of_events=1)
        synchronize {
          until (events ||= []).size == number_of_events
            events += read_many_nonblock(number_of_events)
          end
          events
        }
      end
      
      # reads one Object without blocking if source is empty
      # @return [Object]
      def read_one_nonblock
        synchronize {
          read_many_nonblock.slice!(0)
        }
      end
      
      # reads one Object and blocking if source is empty
      # @return [Object]
      def read_one
        synchronize {
          read_many.slice!(0)
        }
      end
    end
    
    include ReadMethods
    
    # @abstract
    module WriteMethods
      # @abstract 
      # @param  [Integer] number_of_events=1
      def write_many_nonblock(*events)
        raise NotImplemented, 'write_many_nonblock not overridden'
      end
      
      # @abstract 
      # @param  [Integer] number_of_events=1
      def write_many(*events)
        raise NotImplemented, 'write_many not overridden'
      end
      
      alias_method :write_one_nonblock, :write_many_nonblock
      alias_method :write_one, :write_many
    end
    
    include WriteMethods
    
  end
end
end
