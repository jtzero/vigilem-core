require 'spec_helper'

require 'vigilem/core/hooks'

require 'vigilem/core/hooks/meta_callback'
describe Vigilem::Core::Hooks::MetaCallback do
  subject do
    described_class.new do
      self
    end
  end
  
  describe '#ran?' do
    it 'will start false because nothing has ran' do
      expect(subject.ran?).to be_falsey
    end
  end
  
  context 'private' do
    describe '#ran=' do
      it 'sets ran' do
        subject.send(:ran=, true)
        expect(subject.ran?).to be_truthy
      end
    end
  end
  
  shared_examples 'evaluatable' do 
    before(:all) { Context = Class.new unless defined? :Context}
    
    let(:instance) { Context.new }
      
    let!(:result) { subject.send(method_name, instance) }
    
    it 'flags ran? to true' do
      expect(subject.ran?).to be_truthy
    end
    
    it 'runs callbackproc #evaluate' do
      expect(result).to eql(instance)
    end
  end
  
  describe '#evaluate' do
    
    it_behaves_like 'evaluatable' do
      let(:method_name) { :evaluate }
    end
  end
  
  describe '#[]' do
    it_behaves_like 'evaluatable' do
      let(:method_name) { :[] }
    end
  end
  
  describe '#call' do
    When(:result) { subject.call }
    
    it 'flags ran to true' do
      expect(subject.ran?).to be_truthy
    end
    
    it 'will run like Proc' do
      expect(result).to eql(self)
    end
  end
  
end
