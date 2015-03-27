require 'vigilem/core/hub'

describe Vigilem::Core::Hub do
  
  subject { described_class.new([]) }
  
  describe '#initialize' do
    it 'will initialize the buffers' do
      expect(subject.buffers).to_not be_nil
    end
  end
  
  describe '#add_buffer' do
    let(:buffer) { Object.new }
    
    it 'will add to the buffers' do
      subject.add_buffer(buffer)
      expect(subject.buffers).to include(buffer)
    end
  end
  
  describe '#<<' do
    let(:buffer) { Object.new }
    
    it 'will add to the buffers' do
      subject << buffer
      expect(subject.buffers).to include(buffer)
    end
  end
  
  describe '#demux' do
    
    let(:buffer) { [1,2,3] }
    
    let(:buffer2) { %w(a b c) }
    
    let!(:reg) do 
      subject.add_buffer(buffer)
      subject.add_buffer(buffer2)
    end
    
    it 'returns buffers that get the new messages' do
      expect(subject.demux(buffer2, 5)).to eql([buffer])
    end
    
    it 'updates the buffers except the link' do
      subject.demux([], 5)
      expect(buffer).to eql([1,2,3,5])
    end
    
    context 'when buffers eql? each other' do
      let(:ary_buffer) { [] }
      
      let(:ary_buffer2) { [] }
      
      let!(:reg) do 
        subject.add_buffer(ary_buffer)
        subject.add_buffer(ary_buffer2)
      end
      
      it 'updates the buffers except the link' do
        subject.demux(ary_buffer, 5)
        expect(ary_buffer2).to eql([5])
      end
    end
    
  end
end
