require 'spec_helper'

require 'vigilem/core/input_system_handler'

describe Vigilem::Core::InputSystemHandler do
  
  after(:each) do
    (described_class.instance_variables).each do |ivar| 
        described_class.send(:remove_instance_variable, ivar)
    end
  end
  
  class FakeHandler
    include Vigilem::Core::InputSystemHandler
    def initialize
      initialize_input_system_handler
    end
  end
  
  let(:handler) { FakeHandler.new }
  
  describe '#initialize' do
    
    it 'will initialize inbox/buffer' do
      expect(handler.inbox).to_not be_nil
    end
    
    it 'will register the base class when initialized' do
      expect(FakeHandler.all).to include handler
    end
  end
  
end
