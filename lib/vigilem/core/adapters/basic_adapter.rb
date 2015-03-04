require 'observer'

module Vigilem
module Core
module Adapters
  # 
  # 
  module BasicAdapter
    
    include Observable
    
    # 
    # @param  lnk value to assign to @link, defaults to nil
    def initialize_basic_adapter(lnk=nil)
      @link = lnk
    end
    
    # 
    # @param  value
    # @return 
    def link=(value)
      @link = value
      changed
      notify_observers('link', @link)
      @link
    end
    
    # source is more dynamic than link,
    # i.e. and input system handler can have multiple sources
    # or get it's info from a demultiplexer, yet have no direct #link
    def source
      @source || link()
    end
    
   private
    
    # the direct item next in line
    attr_reader :link
    
  end
end
end
end
