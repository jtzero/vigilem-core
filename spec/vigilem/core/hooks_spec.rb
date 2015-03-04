require 'spec_helper'

require 'vigilem/core/hooks'

describe Vigilem::Core::Hooks do
  
  it 'will have hooks as instance method' do
    expect(described_class.method_defined?(:hooks)).to be_truthy
  end
  
  let!(:base) do
    dc = described_class
    Class.new do
      extend dc
    end
  end
  
  let(:callback) do
    Class.new do
      def name
        :testr
      end
      def run
        self
      end
    end
  end
  
  it 'will have class level run_hook method' do
    expect(base).to respond_to(:run_hook)
  end
  
  it 'will have an instance level run_hooks' do
    expect(base.method_defined?(:run_hook)).to be_truthy
  end
  
  it 'will have class level hooks' do
    expect(base).to respond_to(:hooks)
  end
  
  let(:base_instance) { base.new }
  
  let!(:hooks) { base.hooks << callback.new }
  
  it 'will call run on every hook' do
    expect(base.hooks.first).to receive(:run)
    base_instance.run_hook :testr
  end
  
end
