module Vigilem
module Core
  # 
  # observer of components and thier connections
  # the catch is that input_systems don;t have an entry point
  # for determining thier source
  class Pipeline
    attr_reader :device
    
    # 
    # @param [#link] device most likely a Core::Device
    def initialize(device)
      @device = device
      rebuild
    end
    
    extend Support::ObjSpace
    
    # get the next item that #source
    # is pointing to
    # @return 
    def succ
      @iter ||= device
      @iter.respond(:source)
    end
    
    # the start of the pipeline
    # @return [#source]
    def reset_iter
      @iter = device
    end
    
    # rebuilds the cache
    # @return [Array]
    def rebuild
      ary = [device]
      while current = succ
        ary << current
      end
      reset_iter
      cache = ary
    end
    
    # updates the status
    # called when a component changes it's sauce
    # @return [TrueClass]
    def update
      @changed = true
    end
    
    # checks whether or not this item changed
    # @return [TrueClass || FalseClass]
    def changed?
      @changed ||= false
    end
    
    # @return [Array] all the components in the pipeline
    def to_a
      changed? ? rebuild : cache
    end
    
    alias_method :to_ary, :to_a
    
   private
    attr_accessor :cache
  end
end
end
