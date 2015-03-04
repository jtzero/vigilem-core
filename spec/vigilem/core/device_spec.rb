require 'spec_helper'

require 'vigilem/core/device'

describe Vigilem::Core::Device do
  describe '#new' do
    
    Stat = Vigilem::Core::Stat
    
    before(:each) do
      Stat.all << double('fake_stat', :available? => true, :input_system_name => 'guy on the couch')
    end
    
    after(:each) do
      Stat.all.replace([])
    end
    
    subject do
      described_class.new do
        on_os(/.+/) do
          @adaptability_level = 'Tardigrade'
        end
        
        on_input_system(/.+/) do
          @mode = 'stun'
        end
        after_init { @testr = 'test' }
      end
    end
    
    context 'class creation' do
      it 'creates a Class if block given' do
        expect(subject).to be_instance_of(Class)
      end
    end
    
    context 'instantiation' do
      
      it 'throws error when settings are empty' do
        expect { described_class.new }.to raise_error(RuntimeError)
      end
      
      it 'will pass system_checks' do
        expect { subject.new }.to_not raise_error
      end
      
      context 'hooks' do
        it 'runs #on_os hook' do
          expect(subject.new.instance_variable_get(:@adaptability_level)).to eql 'Tardigrade'
        end
        
        it 'runs #on_input_system hook' do
          expect(subject.new.instance_variable_get(:@mode)).to eql 'stun'
        end
        
      end
    end
    
    
  end
  
end
