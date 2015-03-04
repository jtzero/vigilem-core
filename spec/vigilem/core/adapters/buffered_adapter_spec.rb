require 'vigilem/core/adapters/buffered_adapter'

describe Vigilem::Core::Adapters::BufferedAdapter do
  
  it 'is a BufferHandler' do
    expect(described_class).to be < Vigilem::Core::BufferHandler
  end
  
  describe '#initialize_buffered' do
    it %q<init's a buffer_handler and adapter> do
      pending('@todo test')
      raise 'NotImplementedError'
    end
  end
  
end
