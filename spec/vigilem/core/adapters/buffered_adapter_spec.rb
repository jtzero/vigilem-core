require 'vigilem/core/adapters/buffered_adapter'

describe Vigilem::Core::Adapters::BufferedAdapter do
  
  it 'is a BufferHandler' do
    expect(described_class).to be < Vigilem::Core::BufferHandler
  end
  
  describe '#initialize_buffered' do
    
    class BufferedAdapterHost
      include Vigilem::Core::Adapters::BufferedAdapter
      def initialize(lnk=nil, buffer_type=[])
        initialize_buffered(lnk, buffer_type)
      end
    end
    
    it %q<init's a BufferHandler> do
      expect(BufferedAdapterHost.new.buffers).not_to be_nil
    end
    
    it %q<init's an Adapter> do
      expect(BufferedAdapterHost.new('my data source').send(:link)).not_to be_nil
    end
  end
  
end
