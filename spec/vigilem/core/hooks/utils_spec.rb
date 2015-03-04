require 'spec_helper'

require 'vigilem/core/hooks/utils'

describe Vigilem::Core::Hooks::Utils do
  
  before(:all) { TmpClass = Class.new }
  
  # @todo test instances
  describe '#callback_is_in_subclass?' do
    
    before :all do
      TempSubclass = Class.new(TmpClass) do
        def self.callback 
          lambda { puts self }
        end
      end
    end
    
    it 'will determine whether the callback binding is a subclass of context' do
      expect(described_class.callback_is_in_subclass?(TmpClass, TempSubclass.callback)).to be_truthy
    end
    
  end
end