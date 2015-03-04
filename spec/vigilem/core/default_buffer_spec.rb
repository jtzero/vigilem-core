require 'vigilem/core/default_buffer'

describe Vigilem::Core::DefaultBuffer do
  context 'declared type' do
    describe '::wrap' do
      it 'becomes the type passed in' do
        expect(described_class.wrap('').__getobj__).to be_a(String)
      end
    end
  end
  
  context 'default type ([])' do
    it 'defaults the type to an array' do
      expect(described_class.new.__getobj__).to be_an(Array)
    end
  end
end
