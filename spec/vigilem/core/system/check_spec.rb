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
      it 'returns false if the arg passed in does not match an available input_system/Stat' do
        Stat.all.replace([])
        expect(described_class.check[:input_system][/evdev/]).to be_falsey
      end
      
      it 'checks to see if the arg passed in matches an available input_system/Stat' do
        Stat.all.replace([double('fake stat', :input_system_name => 'evdev', :available? => true)])
        expect(described_class.check[:input_system][/evdev/]).to eql(true)
      end
    end
    
  end
end
