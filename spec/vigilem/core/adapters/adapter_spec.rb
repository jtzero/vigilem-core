require 'vigilem/core/adapters/adapter'

describe Vigilem::Core::Adapters::Adapter do
  
  class Host
    include Vigilem::Core::Adapters::Adapter
    
    def initialize(lnk=nil)
      initialize_adapter(lnk)
    end
  end
  
  subject { Host.new }
  
  describe '#attach' do
    it 'will set the link return self' do
      expect(subject).to receive(:link=).with('new').and_return(subject)
      subject.attach('new')
    end
  end
  
  describe '#affix' do
    it 'will set the link and return the new link' do
      expect(subject).to receive(:link=).with('new').and_return('new')
      subject.affix('new')
    end
  end
end
