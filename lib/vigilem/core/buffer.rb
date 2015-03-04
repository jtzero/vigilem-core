require 'vigilem/support/core_ext'

require 'vigilem/support/utils'

module Vigilem
module Core
  # 
  # @abstract
  # minimum compliance #concat, #slice!, #peek
  # buffers are typically String or Array
  module Buffer
    
    # 
    # @param  start_idx_range
    # @param  [Integer] len
    # @return 
    def slice(start_idx_range, len=nil)
      _super_check((method_name = __method__), nil, *[start_idx_range, *len]) do
        self.deep_dup.slice!(start_idx_range, len)
      end
    end
    
    # 
    # used because it's available on both String and Array
    # maybe drop this in favor of shift...
    # @param  [Integer || Range] start_idx_range
    # @param  [Integer] len
    # @return 
    def slice!(start_idx_range, len=nil)
      _super_check_fail_on_error(__method__, nil, *[start_idx_range, *len])
    end
    
    # 
    # @return 
    def shift(n=nil)
      _super_check(__method__, nil, *n) do
        slice!(0, *n)
      end
    end
    
    # @todo   memoization
    # @raise  [RuntimeError] 
    # @return 
    def peek
      _super_check(__method__) do
        if (enum = respond(:each)).respond_to? :peek
          enum.peek
        else
          _super_check_fail_on_error(__method__)
        end
      end
    end
    
    # 
    # @param  other_ary
    # @return 
    def concat(other_buffer)
      _super_check_fail_on_error(__method__, nil, other_buffer)
    end
    
    # 
    # @param  [Integer] len
    # @return [Array<Object, Integer>] [obj #slice!ed, remainder of len]
    def offset!(len)
      Support::Utils.offset!(self, len)
    end
    
    # 
    # @param  [Integer] len
    # @return [Array<Object, Integer>] [obj #slice!ed, remainder of len]
    def offset(len)
      Support::Utils.offset(self, len)
    end
    
    # 
    # @param  [Integer] num
    # @raise  [ArgumentError] 
    # @return 
    def pop(num=nil)
      _super_check((method_name = __method__), nil, *num) do
        raise ArgumentError, 'negative array size' if num < 0
        ret = slice!(-num, num)
        if num.nil? then slice!(-num, num) else Support::Utils.unwrap_ary(ret) end
      end
    end
    
    # 
    # @return [TrueClass || FalseClass]
    def empty?
      _super_check(__method__) do
        begin
          !!peek
        rescue StopIteration
          false
        end
      end
    end
    
    # 
    # @raise  [TypeError]
    # @return [Buffer]
    def deep_dup
      _super_check(__method__) do
        Support::Utils.deep_dup(self)
      end
      rescue TypeError
        raise "#{self} does not respond_to? :slice, :deep_dup, :_dump and no :_dump_data is defined for class #{self.class}"
    end
    
    # 
    # @param  
    # @return [DefaultBuffer]
    def self.new(type=[])
      require 'vigilem/core/default_buffer'
      DefaultBuffer.new(type)
    end
    
   private
    
    # 
    # @param  [Symbol] method_name
    # @param  [Proc] arg_block
    # @param  [Array] args
    # @raise  [RuntimeError] 
    # @return 
    def _super_check_fail_on_error(method_name, arg_block=nil, *args)
      _super_check(method_name, arg_block, *args) do
        raise NoMethodError, "This #{self.inspect} does not respond_to? :#{method_name}"
      end
    end
    
    # checks to see if the method has a super
    # if it does, it calls it, else executes the otherwise block
    # @param  [Symbol] method_name
    # @param  [Proc] arg_block
    # @param  [Array] args
    # @param  [Proc] otherwise
    # @return 
    def _super_check(method_name, arg_block=nil, *args, &otherwise)
      if (obj = respond(:__getobj__)).respond_to?(method_name)
        obj.method(method_name).call(*args, &arg_block)
      elsif (supa = self.class.superclass).method_defined?(method_name)
        supa.instance_method(method_name).bind(self).call(*args, &arg_block)
      else
        otherwise.call
      end
    end
    
  end
end
end
