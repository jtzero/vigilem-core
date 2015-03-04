require 'vigilem/core/buffer_handler'

# @TODO finish
describe Vigilem::Core::BufferHandler do
  
  before :all do
    FakeBHandler = Class.new do 
      include Vigilem::Core::BufferHandler
      def initialize
        initialize_buffer_handler
      end
    end
  end
  
  subject do
    FakeBHandler.new
  end
  
  describe '#initialize_buffer_handler' do
    
    it 'will initialize the default buffer' do
      expect(subject.buffers[:default]).not_to be_nil
    end
  end
  
  describe '#buffer' do
    it 'returns a buffer' do
      expect(subject.buffer).not_to be_nil
      #alias_method :inbox, :buffer
    end
    it 'assigns a new Buffer of type passed in' do
      subject.buffers[:default] = nil
      subject.buffer(:default, '')
      expect(subject.buffer).to be == Vigilem::Core::DefaultBuffer.new('')
    end
  end
  
  describe '#buffered' do
    #@todo
  end
  
  describe '#buffered!' do
    #@todo
  end
  
  context 'private' do
    describe '#buffer=' do
      #alias_method :inbox=, :buffer=
    end
  end
end
