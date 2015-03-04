require 'vigilem/core/adapters/basic_adapter'

describe Vigilem::Core::Adapters::BasicAdapter do
  
  class InitlessBasicHost
    include Vigilem::Core::Adapters::BasicAdapter
  end
  
  class BasicHost
    include Vigilem::Core::Adapters::BasicAdapter
    
    def initialize(lnk=nil)
      initialize_basic_adapter(lnk)
    end
  end
  
  subject { BasicHost.new }
  
  describe '#initialize_basic_adapter' do
    it 'sets @link' do
      expect(InitlessBasicHost.new.instance_variable_defined?(:@link)).to be_falsey
    end
  end
  
  class Observe
    
    attr_writer :notifications
    
    def update(type, value)
      notifications << [type, value]
    end
    
    def notifications
      @notifications ||= []
    end
  end
  
  describe '#link=' do
    it 'will set to changed when link is changed' do
      subject.add_observer(obs = Observe.new)
      subject.link = 'new'
      expect(obs.notifications).to include(['link', 'new'])
    end
  end
  
  describe '#source' do
    
  end
  
  describe '#link' do
    
  end
end
