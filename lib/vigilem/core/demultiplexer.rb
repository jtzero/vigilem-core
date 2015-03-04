require 'observer'

require 'thread_safe'

require 'vigilem/support/core_ext'

require 'vigilem/support/obj_space'

require 'vigilem/support/lazy_simple_delegator'

require 'vigilem/core/multiplexer'

module Vigilem
module Core
  # #shift's from input and distributes it to the 
  # observers
  class Demultiplexer
    include Observable
    
    extend Support::ObjSpace
    
    attr_accessor :input
    
    alias_method :source, :input
    alias_method :source=, :input=
    
    # 
    # @param  [Array<Array<observer_object, Hash{@see #add_observer}>>] observers
    # @param  [(Buffer) #slice!] input_source
    def self.new(input_source=nil, observers=[])
      obj_register(super(input_source, observers))
    end
    
    # 
    # @param  [Array<Array<observer_object, Hash{@see #add_observer}>>] observers
    # @param  [(Buffer) #shift] input_source
    def initialize(input_source=nil, observers=[])
      @input = input_source
      
      add_observers(observers)
    end
    
    # the peers without the Delegators
    # @return [Array]
    def observers
      _observers.map {|obj| obj.respond(:peel) || obj }
    end
    
    alias_method :outputs, :observers
    
    # 
    # @return [Array]
    def _observers
      (@observer_peers ||= ThreadSafe::Hash.new).keys
    end
    
    alias_method :_outputs, :_observers
    
    # @see    Observable#add_observer
    # @param  [Hash] event_opts
    # @option :func
    # @option :type [Integer]
    # @option :types [Array<Integer>]
    # @option :device_name [Regexp]
    # @option :device_names [Array<Regexp>]
    # @option :device [File]
    # @option :devices [Array<File>]
    # @return [Array] [event_opts]
    def add_observer(observer, event_opts={})
      observer = Support::LazySimpleDelegator.new(observer).use_strict_eql if observer.is_a? Array
      _observers
      unless observer.respond_to?(event_opts[:func] ||= :update)
        raise NoMethodError, "observer does not respond to `#{func.to_s}'"
      end
      @observer_peers[observer] = event_opts
    end
    
    alias_method :add_output, :add_observer
    
    # @see    Observable#add_observer
    # @param  [Array<Array<observer_object, Hash{@see add_observer}>>]
    # @return [Array]
    def add_observers(observers_and_opts)
      observers_and_opts.map do |(obs, hsh)|
        add_observer(*[obs, hsh].compact)
      end
    end
    
    alias_method :add_outputs, :add_observers
    
    # 
    # @see    Object#inspect
    # @return [String]
    def inspect
      if input.is_a? Array  # @todo switch from regex
        super.gsub(/@input=.+?(\s+|>)/, "@input=#<#{input.class}:#{Support::Utils.inspect_id(input)} #{input}>\\1")
      else
        super
      end
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
    
    # gets events from input and notifies_observers
    # @param  [Integer] max_number_of_events
    # @return 
    def demux(max_number_of_events=1)
      semaphore.synchronize {
        events = input.shift(max_number_of_events)
        changed
        notify_observers(*events)
      }
    end
    
    # 
    # @see    Observable#notify_observers
    # @param  [Array]
    # @return [TrueClass || FalseClass]
    def notify_observers(*events)
      if defined? @observer_state and @observer_state
        if defined? @observer_peers
          @observer_peers.each do |k, event_opts|
            filtered = self.class.filter_events(events, event_opts)
            k.send event_opts[:func], filtered unless filtered.empty?
          end
        end
        @observer_state = false
      end
    end
    
    alias_method :sweep, :notify_observers
    alias_method :notify_outputs, :notify_observers
    
    # 
    # @param  [Array] events
    # @param  [Hash{@see #add_observer}] event_opts
    # @return [Array]
    def filter_events(events, event_opts)
      self.class.filter_events(events, event_opts)
    end
    
    class << self
      
      # 
      # @param  base
      # @return 
      def inherited(base)
        base.extend Support::ObjSpace
      end
      
      # 
      # @param  [Array<#metadata, #type>] events
      # @param  [Hash{@see #add_observer}] event_opts
      # @return [Array]
      def filter_events(events, event_opts)
        events.select do |event|
          opts = event_opts.select {|k,v| event_option_names.include? k }
          if opts.empty?
            event
          else
            opts.all? do |opt,v|
              opt_vals = [v].flatten
              case opt.to_s
              when /^devices?$/
                opt_vals.any? do |dev| 
                  if (src = event.metadata[:source])
                    File.identical?(dev, src)
                  end
                end
              when /^device_names?$/
                opt_vals.any? {|dev_name| event.metadata[:source].respond.name =~ dev_name }
              when /^types?$/
                opt_vals.any? {|ev_type| event.type == ev_type }
              end
            end
            
          end # else
          
        end
      end
      
      # like first_or_new
      # @return [Demultiplexer]
      def acquire(input_source=nil, observers=[], &block)
        found = all.find(&block)
        if found
          found.add_observers(observers)
        else
          new(input_source, observers)
        end
      end
      
      # 
      # @return [Hash]
      def same_source_check
        all.group_by do |dem| 
          dem.respond(:fileno) || dem
        end.select {|k, v| v.size > 1 }
      end
      
      # 
      # @return [Array<Symbol>]
      def event_option_names
        @event_option_names ||=  option_names - [:func]
      end
      
      # 
      # @return [Array<Symbol>]
      def option_names
        @options ||= [:func, :type, :types, :device_name, :device_names, :device, :devices]
      end
      
    end
  end
  
end
end
