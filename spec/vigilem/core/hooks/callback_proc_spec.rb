require 'spec_helper'

require 'vigilem/core/hooks'

describe Vigilem::Core::Hooks::CallbackProc do
  subject do
    described_class.new do
      self
    end
  end
  
  describe '#evaluate' do
    
    before(:all) { Context = Class.new }
    
    context 'class' do
      
      let!(:result) { subject.evaluate(Context) }
      
      it 'will run in the class context specified' do
        expect(result).to eql(Context)
      end
      
      it '[] will be the same' do
        expect(result).to eql(Context)
      end
      
      it 'will remember the last result' do
        expect(subject.result).to eql(Context)
      end
    end
    
    context 'instance' do
      
      let(:instance) { Context.new }
      
      let!(:result) { subject.evaluate(instance) }
      
      it 'will run in the object context specified' do
        expect(result).to eql(instance)
      end
      
      it '[] will be the same' do
        expect(result).to eql(instance)
      end
      
      it 'will remember the last result' do
        expect(subject.result).to eql(instance)
      end
    end
    
  end
  
  describe '#call' do
    
    let!(:result) { subject.call }
    
    it 'will run like Proc' do
      expect(result).to eql(self)
    end
    
    it 'will remember the result' do
      expect(subject.result).to eql(result)
    end
  end
end
