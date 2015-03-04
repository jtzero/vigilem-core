require 'forwardable'

require 'active_support/concern'

module Vigilem
module Core
  # 
  # 
  module EventHandler
    
    extend Forwardable
    
    extend ActiveSupport::Concern
    
    # 
    # 
    module Utils
      
      # 
      # @param  [#to_s] namespace
      # @return [String] 
      def snakecase_class_name(namespace)
        namespace.to_s.split('::').last.snakecase
      end
      
      # 
      # @param  [Symbol] sym
      # @return [TrueClass || FalseClass]
      def respond_to?(sym, include_all=false)
        on_format?(sym.to_s) || super(sym, include_all)
      end
      
      # does the string passed in start with 'on_'
      # @param  [String] str
      # @return [TrueClass || FalseClass]
      def on_format?(str)
        str.start_with?('on_')
      end
      
      # converts a "on_String" => :String
      # @param  [String] on_name
      # @return [Symbol]
      def type_from_on_format(on_name)
        on_name.split('on_', 2).last.to_sym
      end
    end
    
    include Utils
    extend Utils
    
    module ClassMethods
      
      include Utils
      
      # @todo   Fuzzy is_a? Hash key lookup
      # @return [Hash]
      def type_handles
        @type_handles ||= {} 
      end
      
      # 
      # sets the default_handler, if called without a block, just
      # assigns the default handler to a "default"
      # @param  [Proc] block
      # @return [Proc]
      def default_handler(&block)
        type_handles.default = (block || lambda {|*args, &block| })
      end
      
      # @todo module_function
      # configures how this event handler handles an event
      # @param  type
      # @return [Proc] the block given/registered
      def on(type, opts={}, &block)
        type_name = snakecase_class_name(type)
        on_method = send(:_define_register, type, type_name)
        type_handles[type] = send(:_define_handler, type_name, &block)
        on_method.call(&block)
      end
      
      alias_method :register_handle, :on
      
     private
      
      # defines `on_#{event_type}'
      # @param   type
      # @param  [String] type_name
      # @param  [Proc] block
      # @return [Method]
      def _define_register(type, type_name)
        define_singleton_method(on_method_name = :"on_#{type_name}") {|opts={}, &blk| type_handles[type] = blk }
        define_method(on_method_name) {|opts={}, &blk| self.class.send(on_method_name, opts, &blk) }
        method(on_method_name)
      end
      
      # defines `handle_#{event_type}'
      # @param  [String] type
      # @param  [Proc] block
      # @return [Proc]
      def _define_handler(type_name, &block)
        define_method(handler_name = :"handle_#{type_name}", &block)
        block
      end
      
    end
    
    # 
    # @return [Hash]
    def type_handles
      self.class.type_handles
    end
    
    # to trigger the handling, either use handle(event, opts={}) or handle_#{type}
    # configures how this event handler handles an event
    # @param  [#to_s] type
    # @return [Proc] the block given/registered
    def on(type, &block)
      define_singleton_method(on_method_name = :"on_#{class_name = snakecase_class_name(type)}") {|&blk| type_handles[type] = blk }
      ret = send on_method_name, &block
      define_singleton_method(handler_name = :"handle_#{class_name}", &type_handles[type])
      ret
    end
    alias_method :register_handle, :on
    
    # 
    # @param  event, the event to handle
    # @param  [Array] 
    # @return results of the Proc registered to the type_handless
    def handle(event, *args, &block)
      if handler = type_handles[event.class]
        handler.call(event, *args, &block)
      end
    end
    
    # 
    # @param  event, the event to handle
    # @param  [Array] 
    # @return results of the Proc registered to the type_handless 
    def handle!(event, *args, &block)
      if ret = handle(event, *args, &block)
        ret
      else
        raise NotImplementedError, "No handler found for #{key.class}:#{key},#{block} and no default handler set"
      end
    end
    
    #
    # @param  [Proc]
    # @return 
    def default_handler(&block)
      self.class.default_handler(&block)
    end
    
  end
end
end
