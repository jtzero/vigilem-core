require 'active_support/concern'

require 'vigilem/support/obj_space'

require 'vigilem/support/utils'

module Vigilem
module Core
  # 
  # 
  module Multiplexer
    
    extend Support::ObjSpace
    
    extend ActiveSupport::Concern
    
    attr_writer :inputs
    
    attr_accessor :out
    
    alias_method :output, :out
    alias_method :output=, :out=
    
    # 
    # @param  [Array<IO || Array>] in_ios_or_arrays
    # @param  [Array<#<< || #concat>] out
    # @return 
    def initialize_multiplexer(in_ios_or_arrays, out=nil)
      @inputs = in_ios_or_arrays
      
      @out = out
      self.class.obj_register(self)
      multiplexers = ::Vigilem::Core::Multiplexer.all
      if (ties = multiplexers.flat_map {|muxer| self.intersect muxer }).any?
        raise NotImplemented, "Multiplexers cannot share the same inputs `#{ties.inspect}'"
      end
      multiplexers << self
    end
    
    # @todo   change name to select?
    # @return [Array<IO> || NilClass] objects ready to be read, or nil 
    #                                 if nothing is to be read
    def ready?
      if not (ios = inputs.select {|io| io.respond_to? :to_io }).empty?
        @ready, others = IO.select(ios, nil, nil, 0)
      end
      @ready ||= []
      @ready += inputs.select {|ary| ary.respond_to?(:empty?) and ary.empty? }
    end
    
    # 
    # @raise  [ArgumentError]
    # @return [Array]
    def __sweep__(len)
      recursive_check(RuntimeError)
      sweep(len)
    end
    
    # 
    # @param  [Integer] num
    # @return 
    def sweep(num)
      raise NotImplemented, "#sweep method not defined on `#{self}' needs to be overriden"
    end
    
    # 
    # pushes the converted array from #sweep to #out
    # @param  [Integer] len
    # @return [Array]
    def mux(len)
      ary = __sweep__(len)
      if out.respond_to? :concat
        out.concat(ary)
      elsif out.respond_to? :<<
        ary.each {|item| out << item }
      else
        raise TypeError, "`#{self}'#out is `#{self.out.inspect}' and does not respond to #concat or #<<"
      end
      out.flush if out.respond_to? :flush
      ary
    end
    
    # 
    # @return [Array]
    def inputs
      @inputs ||= []
    end
    
    # adds a inputs and runs a uniq
    # @param  [Array<IO || Array>] added_inputs
    # @return [Array<IO || Array>] 
    def add_inputs(*added_inputs)
      if not added_inputs.empty?
        (self.inputs += added_inputs).uniq! {|obj| obj.object_id }
        recursive_check
      end
      self.inputs
    end
    
    # 
    # 
    module ClassMethods
      
      include Support::ObjSpace
      
      # 
      # @param [Module] base
      def self.extended(base)
        base.extend Support::ObjSpace
      end
      
    end
    
    extend ClassMethods
    
    # 
    # @see    Object#inspect
    # @return [String]
    def inspect
      if out.is_a? Array  # @todo switch from regex
        updated_out = super.gsub(/@out=.+?(\s+|>)/, "@out=#<#{out.class}:#{Support::Utils.inspect_id(out)} #{out}>\\1")
        
        if inputs.any? {|inp| inp.is_a? Array }
          str_ary_bdy = inputs.map do |inp| 
            if inp.is_a?(Array) 
              "#<#{inp.class}:#{Support::Utils.inspect_id(inp)} #{inp}>"
            else
              inp
            end
          end.join(', ')
          updated_out.gsub(/@inputs=.+?(\s+|>)/, "@inputs=[#{str_ary_bdy}]\\1")
        end || updated_out
        
      else
        super
      end
    end
    
    # compares the inputs to the list or multiplexer given
    # @param  [Multiplexer || Array<IO> || Array<Array<>>] other_mux_or_ios_or_arrays
    # @return [Array]
    def intersect(*other_mux_or_ios_or_arrays)
      ios, non_fileno = self.inputs.partition {|inpt| inpt.respond_to?(:fileno) }
      ios_fn = ios.map(&:fileno)
      
      non_fileno.map!(&:object_id)
      
      ary = other_mux_or_ios_or_arrays.respond_to?(:inputs) ? other_mux_or_ios_or_arrays.inputs : other_mux_or_ios_or_arrays
      ary.select do |inp|
        if inp.respond_to? :fileno
          ios_fn.include? inp.fileno
        else
          non_fileno.include? inp.object_id  #default compares by #hash
        end
      end
    end
    
   private
    # checks to make sure that an input doesn't match an output thus causing
    # a recursive loop, raises an error if found
    # @raise  [ArgumentError]
    # @return 
    def recursive_check(arg_type=ArgumentError)
      raise arg_type, "Recursive multiplexer `#{self}' has `#{out}' as an input and output" unless intersect(out).empty?
    end
  end
end
end
