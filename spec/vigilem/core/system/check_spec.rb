require 'spec_helper'

require 'vigilem/support/system'

require 'vigilem/core/system'

describe Vigilem::Core::System do
  
  describe '::check' do
    describe ':os' do
      it 'checks to see if the os is the same as the argument' do
        expect(described_class.check[:os].call(/#{described_class.os}/i)).to be_truthy
      end
    end
    
    describe ':input_system' do
      it 'checks to see if the arg passed in matches an available input_system/Stat' do
        pending('test gets implemented')
        raise NotImplementedError
      end
    end
    
  end
end