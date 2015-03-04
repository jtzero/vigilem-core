require 'vigilem/core/buffer'

require 'delegate'

describe Vigilem::Core::Buffer do
  
  
  context 'private' do
    
    before :all do
      SuperCheck = Class.new(String) { include ::Vigilem::Core::Buffer }
    end
    
    before :all do
      SuperDelegateCheck = Class.new(SimpleDelegator) { include ::Vigilem::Core::Buffer }
    end
    
    subject { SuperCheck.new('abcdef') }
    
    describe '_super_check' do
      it 'will call the superclass method if it exists' do
        expect(subject.send(:_super_check, :slice, nil, 1,2)).to eql('bc')
      end
      
      it %Q(will call the otherwise block if the superclass doesn't have the method) do
        expect(subject.send(:_super_check, :dice, nil, 1,2) { '$' }).to eql('$')
      end
      
      context 'delegate' do 
        subject do
          SuperDelegateCheck.new(%Q(ces't cheese))
        end
        
        it 'will call __getobj__ if the class responds to it' do
          expect(subject.send(:_super_check, :slice, nil, 7,2)).to eql('he')
        end
      end
      
    end
  end
  
  class StrBuffer
    include ::Vigilem::Core::Buffer
    
    def initialize(str=nil)
      @str = str || 'I am rawrg!'
    end
    
    def _dump(level)
      Marshal.dump(@ary)
    end
    
    def self._load(str)
      self.new(*Marshal.load(str))
    end
    
    def slice!(*args)
      self.class.new(*@str.slice!(*args))
    end
    
    def concat(other_str)
      self.class.new(*@str.concat(other_str))
    end
    
    def ==(other_obj)
      @str == other_obj.instance_variable_get(:@str)
    end
    
    def length
      @str.length
    end
  end
  
  class AryBuffer
    include ::Vigilem::Core::Buffer
    
    def initialize(*ary)
      @ary = if ary.empty? then %w(a b c d) else ary end
    end
    
    def _dump(level)
      Marshal.dump(@ary)
    end
    
    def self._load(str)
      self.new(*Marshal.load(str))
    end
    
    def slice!(*args)
      self.class.new(*@ary.slice!(*args))
    end
    
    def concat(other_str)
      self.class.new(*@ary.concat(other_str))
    end
    
    def ==(other_obj)
      @ary == other_obj.instance_variable_get(:@ary)
    end
    
    def length
      @ary.length
    end
  end
  
  class FailBuffer
    include ::Vigilem::Core::Buffer
    def _dump(level)
      Marshal.dump(@ary)
    end
    
    def self._load(str)
      self.new(*Marshal.dump(str))
    end
    
    def initialize
      @str = %w(a b c d)
    end
    
    def concat(other_str)
      @str.concat(other_str)
    end
  end
  
  describe '#offset!' do
    context 'will slice! from the @input_buffer and return the remainder' do
      
      context StrBuffer do 
        it 'buffer > len' do
          expect(subject.offset!(4)).to be == [described_class.new('I am'), 0]
        end
        it 'buffer < len' do
          expect(subject.offset!(13)).to be == [described_class.new('I am rawrg!'), 2]
        end
      end
      context AryBuffer do
        it 'buffer > len' do
          expect(subject.offset!(3)).to be == [described_class.new('a', 'b', 'c'), 0]
        end
        
        it 'buffer < len' do
          expect(subject.offset!(9)).to be == [described_class.new('a', 'b', 'c', 'd'), 5]
        end
      end
      
    end
  end
  
  shared_examples 'modifier!' do 
    before(:all) { @buffer = described_class.new }
      
    let(:result) { @buffer.send(method_name, *args) }
    
    it 'return a subset of the original' do
      expect(result).to be == described_class.new(*result_match)
    end
    
    it 'will modify the original buffer' do
      expect(@buffer).to be == described_class.new(*buffer_state)
    end
  end
  
  shared_examples 'modifier' do 
    before(:all) { @buffer = described_class.new }
    
    let(:result) { @buffer.send(method_name, *args) }
    
    it 'return a subset of the original' do
      expect(result).to be == described_class.new(*result_match)
    end
    
    it 'will not effect the original buffer' do
      expect(@buffer).to be == described_class.new(*buffer_state)
    end
  end
  
  describe '#slice' do
    context AryBuffer do
      it_behaves_like 'modifier' do
        let(:method_name) { :slice }
        let(:args) { [1, 2] }
        let(:result_match) { %w(b c) }
        let(:buffer_state) { %w(a b c d) }
      end
    end
    
    context StrBuffer do
      it_behaves_like 'modifier' do
        let(:method_name) { :slice }
        let(:args) { [1, 2] }
        let(:result_match) { ' a' }
        let(:buffer_state) { 'I am rawrg!' }
      end
    end
  end
  
  describe '#slice!' do
    context AryBuffer do
      it_behaves_like 'modifier!' do
        let(:method_name) { :slice! }
        let(:args) { [1, 2] }
        let(:result_match) { %w(b c) }
        let(:buffer_state) { %w(a d) }
      end
    end
    
    context StrBuffer do
      it_behaves_like 'modifier!' do
        let(:method_name) { :slice! }
        let(:args) { [1, 2] }
        let(:result_match) { ' a' }
        let(:buffer_state) { 'Im rawrg!' }
      end
    end
  end
  
  describe 'concat' do
    context AryBuffer do
      it_behaves_like 'modifier!' do
        let(:method_name) { :concat }
        let(:args) { [[1]] }
        let(:result_match) { %w(a b c d) + [1] }
        let(:buffer_state) { %w(a b c d) + [1] }
      end
    end
    
    context StrBuffer do
      it_behaves_like 'modifier!' do
        let(:method_name) { :concat }
        let(:args) { 'E>' }
        let(:result_match) { 'I am rawrg!E>' }
        let(:buffer_state) { 'I am rawrg!E>' }
      end
    end
  end
end
