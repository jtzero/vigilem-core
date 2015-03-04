require 'spec_helper'

require 'vigilem/core/abstract_device'

describe Vigilem::Core::AbstractDevice do
  
  describe '#setting?' do
    describe 'will test whether or not the hook is a setting' do 
      context 'Hook' do
        let(:hook) { ::Vigilem::Core::Hooks::Hook.new('tmp') }
        
        let!(:callbacks) { hook << ::Vigilem::Core::Hooks::Callback.new { true }  }
        
        it 'will pass before ran' do
          expect(subject.setting?(hook)).to be_truthy
        end
        
        it 'will pass after ran' do
          expect(subject.setting?(hook)).to be_truthy
        end
      end
      
      context 'ConditionalHook' do
        context 'passes' do
          let(:hook) do 
            ::Vigilem::Core::Hooks::ConditionalHook.new('tmp') do
              condition { true }
            end
          end
          
          let!(:callbacks) { hook << ::Vigilem::Core::Hooks::Callback.new { true }  }
          
          it 'will fail before ran' do
            expect(subject.setting?(hook)).to be_falsey
          end
          
          it 'will be a setting when condition passes' do
            hook.call
            expect(subject.setting?(hook)).to be_truthy
          end
        end
        
        context 'fails' do
          let(:hook) do 
            ::Vigilem::Core::Hooks::ConditionalHook.new('tmp') do
              condition { false }
            end
          end
          
          let!(:callbacks) { hook << ::Vigilem::Core::Hooks::Callback.new { true }  }
          
          it 'will not be a setting when the condition fails' do
            hook.call
            expect(subject.setting?(hook)).to be_falsey
          end
        end
        
      end
    end
  end
  
  describe '#new' do
    
    it 'will have one init setting after_init' do
      expect(described_class.new.settings.first.name).to eql(:after_init)
    end
    
    context 'system checks' do
      
      it 'runs the system_check' do
        expect_any_instance_of(described_class).to receive(:run_system_checks)
        described_class.new
      end
      
      it 'will add to settings when the check passes' do
        hook = ::Vigilem::Core::Hooks::ConditionalHook.new(:on_always, 
                             {:type => :system_check, :inheritable => false }) { condition { true } }
        described_class.hooks << hook
        hook << lambda { 'do something' }
        abs = described_class.new
        expect(abs.settings).to_not be_empty
      end
    end
  end
  
  describe 'pipeline building' do
    before :all do
      class Cheese
        def yarg?
          puts 'yarg!'
        end
      end
    end
    context 'after_import' do
      let(:cheese) { Cheese.new }
      
      it 'will set @delegate_sd_obj to the import arg' do
        subject.import(cheese)
        expect(subject.instance_variable_get(:@delegate_sd_obj)).to eql cheese
      end
    end
  end
end
