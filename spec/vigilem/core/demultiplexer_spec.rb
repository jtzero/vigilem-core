require 'spec_helper'

require 'tempfile'

require 'vigilem/core/demultiplexer'

describe Vigilem::Core::Demultiplexer do
  
  after(:each) do
    (described_class.instance_variables).each do |ivar| 
        described_class.send(:remove_instance_variable, ivar)
    end
  end
  
  class OutEvent < Struct.new(:metadata, :type); end
  
  let(:outputs) { [[[], {:func => :concat}], [[], {:func => :concat}], [[], {:func => :concat}]] }
  
  let(:input) { [] }
  
  let(:device_one) do 
    t = Tempfile.new('dev')
    def t.name
      'at keyboard'
    end
    t
  end
  
  let(:device_two) do 
    t = Tempfile.new('dev2')
    def t.name
      'wheel mouse'
    end
    t
  end
  
  let(:devices) { [device_one, device_two] }
  
  let(:events) do
    [
      OutEvent.new({:source => devices.first}),
      OutEvent.new({:source => devices.last}),
      OutEvent.new({}, 1),
      OutEvent.new({}, 2)
    ] 
  end
  
  context 'class-level' do
    
    describe '#option_names' do
      it 'returns a list of options for this observer' do
        expect(described_class.option_names).to all(be_a(Symbol))
      end
    end
    
    describe '#event_option_names' do
      it 'returns the event option Symbols' do
        good_opt = described_class.event_option_names
        expect(described_class.event_option_names).to all(be_a(Symbol)) and not include(:func)
      end
    end
    
    describe '::all' do
      it 'defaults to []' do
        expect(described_class.all).to be_empty
      end
    end
    
    describe '::filter_events' do
      
      it 'filters events if the device is the same as an event source' do
        expect(described_class.filter_events(events, {:device => device_one })).to eql(events.take(1))
      end
      
      it 'filters events if a device is the same as an event source' do
        expect(described_class.filter_events(events, {:devices => devices })).to eql(events.take(2))
      end
      
      it 'filters events if the Regexp matches an event source name' do
        expect(described_class.filter_events(events, {:device_name => /keyboard/ })).to eql(events.take(1))
      end
      
      it 'filters events if a Regexp matches an event source name' do
        expect(described_class.filter_events(events, {:device_names => [/keyboard/, /mouse/] })).to eql(events.take(2))
      end
      
      it 'filters events if the type is the same as an event type' do
        expect(described_class.filter_events(events, {:type => 1 })).to eql([events[2]])
      end
      
      it 'filters events if a type is the same as an event type' do
        expect(described_class.filter_events(events, {:types => [1, 2] })).to eql(events[2,2])
      end
    end
    
  end
  
  describe '#filter_events' do
    it 'calls the clas level filter events' do
      allow(described_class).to receive(:filter_events)
      expect(described_class).to receive(:filter_events)
      subject.filter_events([], {})
    end
  end
  
  describe '#outputs' do
    it 'starts empty' do
      expect(subject.outputs).to be_empty
    end
  end
  
  describe '#input' do
    it 'starts empty' do
      expect(subject.input).to be_nil
    end
  end
  
  describe '#add_observer' do
    
    it 'returns the opts args passed in (like Observerable)' do
      expect(subject.add_observer(*outputs.first)).to eql(outputs.first.last)
    end
    
    it 'adds to #ouputs' do
      subject.add_observer(*outputs.first)
      expect(subject.outputs).to be == outputs.first.take(1)
    end
  end
  
  describe '#initialize' do
    
    subject { described_class.new(input, outputs) }
    
    it 'sets #outputs' do
      expect(subject.outputs).to eql(outputs.map(&:first))
    end
    
    it 'sets #input' do
      expect(subject.input).to eql(input)
    end
    
    it 'adds it to #all' do
      expect(described_class.all).to eql([subject])
    end
    
  end
  
  describe '#notify_observers' do
    it 'pushes passed in events to observers' do
      arg = described_class.new(input, outputs)
      arg.changed
      arg.notify_observers(*events)
      expect(outputs.flat_map(&:first)).not_to be_empty
    end
  end
  
  describe '#demux' do
    it 'pulls from the input and pushes to the correct observers' do
      arg = described_class.new(input, outputs)
      (arg.input ||= []) << events.first
      arg.demux
      expect(outputs.flat_map(&:first)).to all(be_a(OutEvent))
    end
  end
  
end
