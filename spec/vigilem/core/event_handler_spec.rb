
require 'vigilem/core/event_handler'

describe Vigilem::Core::EventHandler do
  
  class EventHandlerHost
    include Vigilem::Core::EventHandler
  end
  
  subject { EventHandlerHost.new }
  
  describe '#type_handles' do
    
    it 'returns a Hash' do
      expect(subject.type_handles).to be_a(Hash)
    end
  end
  
  context 'register, execution' do
    
    let(:handler) do 
      lambda do |event|
        ["I'm handling it", event]
      end
    end
    
    before :each do
      subject.on(:my_event, &handler)
    end
    
    describe '#on/#register' do
      it 'adds a block to the hash with the key == type arg' do
        expect(subject.type_handles[:my_event]).to eql(handler)
      end
    end
    
    describe '#handle' do
      
      class Event 
      end
      
      class UnknownEvent
      end
      
      let(:event) do
        Event.new
      end
      
      let(:handler) do 
        lambda do |event|
          ["I'm handling it", event]
        end
      end
      
      it 'executes the registered block with the event as arg' do
        subject.on(Event, &handler)
        expect(subject.handle(event)).to eql(["I'm handling it", event])
      end
      
      it 'returns nil when event is not registered/handle-able' do
        subject.on(Event, &handler)
        expect(subject.handle(UnknownEvent.new)).to be_nil
      end
    end
    
    let(:test_name) { 'on_test_event' }
    
    describe '#type_from_on_format' do
      it 'strips out the event type from the on_#{event_type} format' do
        expect(described_class.type_from_on_format(test_name)).to eql(:test_event)
      end
    end
    
    describe '::type_from_on_format' do
      it 'returns whether or not the string is in on_#{event_type} format' do
        expect(described_class.type_from_on_format(test_name)).to be_truthy
      end
    end
    
    describe '#respond_to?' do
      it 'responds to items in the on_#{type} format' do
        expect(described_class.respond_to?(test_name)).to be_truthy
      end
    end
    
    context 'private' do
      
      describe '_define_register' do
        
        it 'will not respond to direct access' do
          expect { subject.class._define_register }.to raise_error(NoMethodError, /private method `_define_register'/)
        end
        
        class SomeEvent; end
        
        let!(:run_method) { subject.class.send(:_define_register, SomeEvent, 'some_event') }
        
        it 'defines the class_method on_#{type} method' do
          expect(subject.class).to respond_to(:on_some_event)
        end
        
        it 'defines the instance_method on_#{type} method' do
          expect(subject.class.method_defined?(:on_some_event)).to be_truthy
        end
        
        it 'returns the method defined' do
          expect(run_method).to be_a(Method)
        end
        
      end
      
      describe '_define_handler' do
        
        it 'will not respond to direct access' do
          expect { subject.class._define_handler }.to raise_error(NoMethodError, /private method `_define_handler'/)
        end
        
        class SomeEvent; end
        
        let!(:run_method) { subject.class.send(:_define_handler, 'some_event') {|event| "this is some_event #{event}" } }
        
        it 'defines the instance_method on_#{type} method' do
          expect(subject.class.method_defined?(:handle_some_event)).to be_truthy
        end
        
        it 'returns the method defined' do
          expect(run_method).to be_a(Proc)
        end
        
      end
    end #context 'private'
    
  end
  
end
