require 'spec_helper'

require 'vigilem/core/hooks'

describe Vigilem::Core::Hooks::Hook do
  
  subject { described_class.new(:testr) }
  
  describe '#new' do
    
    it 'to yield itself' do
      expect {|b| described_class.new(:testr, &b).to yield_control }
    end
    
  end
  
  context 'after initialized' do
    
    let!(:init_size) { subject.callbacks.size }
    
    describe '#<<' do
      
      let!(:callbacks) { subject << lambda { self } }
      
      it 'should increase callbacks by one' do
        expect(subject.callbacks.size).to eql(init_size + 1)
      end
      
      it 'will return a full the list of callbacks' do
        expect(callbacks).to equal(subject.callbacks)
      end
      
      it 'will convert procs to Callbacks' do
        expect(callbacks.all? {|cb| cb.is_a? Vigilem::Core::Hooks::Callback }).to be_truthy
      end
    end
    
    describe '#add' do
      let!(:callbacks) { subject.add { self } }
      
      it 'should increase callbacks by one' do
        expect(subject.callbacks.size).to eql(init_size + 1)
      end
      
      it 'will return a full the list of callbacks' do
        expect(callbacks).to equal(subject.callbacks)
      end
      
      it 'will convert procs to Callbacks' do
        expect(callbacks.all? {|cb| cb.is_a? Vigilem::Core::Hooks::Callback }).to be_truthy
      end
    end
    
    describe '#callbacks' do
      
      let(:sub_callback) do 
          class TmpSubClass < self.class
            lambda { self }
          end
        end 
      
      let!(:all_callbacks) { subject << sub_callback }
      
      it 'filters out subclass callbacks when given context/scope' do
        expect(subject.callbacks(self).none? {|cb| cb.source_location == sub_callback.source_location }).to be_truthy
      end
      
    end
    
    context 'execution' do
      
      let!(:callback1) { subject.add { self }.last }
        
      let!(:callback2) { subject.add { self.class }.last }
      
      describe '#call' do
        
        it 'will execute callbacks in the context which they where created' do
          expect(subject.call()).to eql([self, self.class])
        end
      end
      
      describe '#run' do
        
        let!(:context) { (FakeContext = Class.new).new }
        
        it 'will execute callbacks in the context which is passed in' do
          expect(subject.run(context)).to eql([context, FakeContext])
        end
      end
    end
    
    describe '#default_body' do
      
      it 'will return a Proc' do
        expect(subject.default_body).to be_a(Proc)
      end
      
    end
    
    describe '#bind' do
    
      let!(:context) do 
          local = subject
          Class.new do 
            extend Vigilem::Core::Hooks
            local.bind(self)
          end 
        end
      
      it 'will add hook as singleton_method' do
        expect(context.respond_to?(:testr)).to be_truthy
      end
      
      describe '#owner' do
        it 'wil be the value of context' do
          expect(subject.owner).to eql(context)
        end
      end
      
    end
    
    describe '#generate' do
    
      let!(:context) do
          local = subject
          Class.new do 
            extend Vigilem::Core::Hooks
            local.generate(self)
          end.new
        end
      
      it 'will add hook as instance_method' do
        expect(context.respond_to?(:testr)).to be_truthy
      end
      
      describe '#owner' do
        it 'wil be the value of context' do
          expect(subject.owner).to eql(context.class)
        end
      end
      
    end
    
    describe '#body' do
      
      it 'will return default_proc when not set' do
        expect(subject.send(:body)).to equal(subject.default_body)
      end
      
      let(:nw_body) { lambda { puts 'test' } }
      
      it 'will return a block when given one' do
        expect(subject.send(:body, &nw_body)).to eql(nw_body)
      end
      
      context 'generating' do
        
        subject do
          described_class.new(:bdy) do
            body { 'test' }
          end
        end
        
        let!(:context) do
            local = subject
            Class.new do 
              extend Vigilem::Core::Hooks
              local.generate(self)
            end.new
          end
        
        it 'will set the prco to be generated on the class' do
          expect(context.bdy).to eql('test')
        end
        
        context 'binding' do
          subject do
            described_class.new(:bdy) do
              body { 'test' }
            end
          end
          
          let!(:context) do
              local = subject
              Class.new do 
                extend Vigilem::Core::Hooks
                local.bind(self)
              end
            end
          
          it 'will set the proc to be binded on the class' do
            expect(context.bdy).to eql('test')
          end
        end
        
      end
    end
    
    describe '::enumerate' do
      
      let(:call_backs) do 
        [ Vigilem::Core::Hooks::CallbackProc.new {|arg| self }, 
          Vigilem::Core::Hooks::CallbackProc.new {|arg| self.class } ]
      end
      
      it 'will accept args with a list of callbacks and enumerate through them passing a long the args' do
        expect(call_backs.first).to receive(:call).with('test').and_return('test')
        expect(call_backs.last).to receive(:call).with('test').and_return(String)
        described_class.send(:enumerate, call_backs, :args => 'test')
      end
      
      it 'will return the results' do
        expect(described_class.send(:enumerate, call_backs, :args => 'test')).to eql([self, self.class])
      end
      
      it 'will accept a block and yield a meta_callback' do
        expect {|b| described_class.send(:enumerate, call_backs, &b).to yield_with_args(MetaCallback) }
      end
      
      it 'will accept an arg of :context and evaluate the callbacks in that context' do
        expect(call_backs.first).to receive(:evaluate).with(self, 'test').and_return(self)
        expect(call_backs.last).to receive(:evaluate).with(self, 'test').and_return(String)
        described_class.send(:enumerate, call_backs, :context => self, :args => 'test')
      end
    end
    
    
  end
end
