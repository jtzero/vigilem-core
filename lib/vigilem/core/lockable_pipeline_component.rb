require 'vigilem/support/core_ext'

module Vigilem
module Core
  # 
  module LockablePipelineComponent
    
    # 
    # name collision with demultiplexer and bufferhandler
    def semaphore
      @semaphore ||= (semaphore! || Monitor.new)
    end
    
    # 
    # checks #source component for #semaphore without memoization
    def semaphore!
      self.respond.source.respond.semaphore
    end
    
    # 
    # 
    def synchronize
      semaphore.synchronize do
        yield
      end
    end
    
  end
end
end
