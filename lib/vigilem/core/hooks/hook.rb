require 'vigilem/core/hooks/utils'

require 'vigilem/core/hooks/callback_proc'

require 'vigilem/core/hooks/meta_callback'

module Vigilem
module Core::Hooks
  # 
  # bindable group of callbacks
  class Hook
    
    attr_reader :name, :options, :owner
    
    # @param  hook_name
    # @param  [Hash] options
    # @param  [Proc] config
    def initialize(hook_name, options={}, &config)
      @name = hook_name
      options[:inheritable] = true if options[:inheritable].nil?
      (@options = options).freeze
      @callbacks = []
      instance_eval(&config) if block_given?
    end
    
    # 
    # @return [TrueClass || FalseClass]
    def inheritable?
      !!@options[:inheritable]
    end
    
    # 
    # @param  callback
    # @return 
    def <<(callback)
      @callbacks << (callback.is_a?(Callback) ? callback : CallbackProc.new(&callback))
    end
    
    # 
    # @see    #<<
    # @param  [Proc] callback
    # @return 
    def add(&callback)
      self << callback
    end
    
    # 
    # @param  context
    # @return 
    def callbacks(context=nil)
      if context then @callbacks.reject {|cb| Utils.callback_is_in_subclass?(context, cb) } else @callbacks end
    end
    
    # 
    # @param  [Array] args
    # @param  [Proc] block
    # @return [Array]
    def call(*args, &block)
      enumerate({:args => args, :block => block }, &on_run)
    end
    
    # 
    # @param  context
    # @param  [Array] args
    # @param  [Proc] block
    # @return [Array]
    def run(context, *args, &block)
      enumerate({:args => args, :block => block, :context => context }, &on_run)
    end
    
    alias_method :evaluate, :run
    
    # 
    # 
    # @return [Proc]
    def default_body
      @default_body ||= begin
          hook = self
          lambda do |opts={}, &block|
            raise 'block not given' unless block
            hook.callbacks << CallbackProc.new(opts, &block)
          end
        end
    end
    
    # @return [String]
    def to_s
      "#{super().chomp('>')} #{name}>"
    end
    
    # @return [Array]; [name, self]
    def to_ary
      [self.name, self]
    end
    
    # @return {name => self}
    def to_h
      {self.name => self }
    end
    
    # 
    # @return [Proc]
    def to_proc
      body()
    end
    
    # @todo   Error for name collision
    # @param  context the object to bind this hook to
    # @return the result of the evaluation
    def bind(context)
      hook, hook_body = self, body()
      self.owner = Support::Utils.get_class(context)
      ret = context.instance_eval do
        define_singleton_method(hook.name, &hook_body)
      end
      owner.hooks << hook
      ret
    end
    
    # uses define_method instead
    # of define_singleton_method like bind!
    # 
    # hmm I could have one hook that spans multiple instances, bad or good?
    # doesn't work with @owner
    # @param  [Class] klass
    # @return 
    def generate(klass)
      hook, hook_body = self, body()
      self.owner = klass
      ret = klass.instance_eval do
        define_method(hook.name, &hook_body)
      end
      klass.hooks << hook
      ret
    end
    
    class << self
      
      # 
      # @param  [Array<Callback>] call_backs
      # @param  [Array] args
      # @param  [Proc] block
      # @return [Array]
      def enumerate(call_backs, args={}, &block)
        call_backs.inject([]) do |results, callback|
          mcb = MetaCallback.new(callback)
          if block
            yield(mcb)
          elsif args.has_key?(:context)
            mcb.evaluate(args[:context], *args[:args], &args[:block])
          else
            mcb.call(*args[:args], &args[:block])
          end
          results << mcb.result if mcb.ran?
          results
        end
      end
    end
    private_class_method :enumerate
    
   private
    
    attr_writer :owner
    
    # 
    # @param  [Hash] args
    # @param  [Proc] block
    # @return [Array]
    def enumerate(args={}, &block)
      self.class.send :enumerate, callbacks(args[:context]), args, &block
    end
    
    # 
    # @param  [Proc] block
    # @return [Proc] 
    def on_run(&block)
      @on_run = block
    end
    
    # 
    # @param  [Proc] block
    # @return [Proc]
    def body(&block)
      if block
        @body = block
      else
        @body ||= default_body
      end
    end
    
  end
end
end
