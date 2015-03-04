require 'spec_helper'

require 'tempfile'

require 'vigilem/core/transfer_agent'

describe Vigilem::Core::TransferAgent do
  
  let(:outputs) { [[[], {:func => :concat}], [[], {:func => :concat}], [[], {:func => :concat}]] }
  
  let(:connection) { [] }
  
  before(:each) do
    @ios = [Tempfile.new('foo'), Tempfile.new('bar'),
                      Tempfile.new('fizz'), Tempfile.new('buzz')]
  end
  
  class TAMultiplexerHost
    include Vigilem::Core::Multiplexer
    def initialize(inpts, out=nil)
      initialize_multiplexer(inpts, out)
    end
    
    def sweep(events=1)
      inputs.flat_map do |ipt|
        begin
          ipt.readline.chomp("\r").chomp("\n")
        rescue EOFError
        end
      end.compact.sort {|a,b| a.split('|').first.to_i <=> a.split('|').first.to_i }
    end
    
  end
  
  after(:each) do
    @ios.map(&:close)
    described_class.instance_variable_set(:@transfer_agents, nil)
  end
  
  let(:demuxer) { Vigilem::Core::Demultiplexer.new(connection, outputs) }
  
  let(:muxer) { TAMultiplexerHost.new(@ios) }
  
  describe '#initialize' do
    it 'connects the demultiplexer and multiplexer' do
      ta = described_class.new(demuxer, muxer)
      expect(ta.multiplexer.out).to eql(ta.demultiplexer.input)
    end
  end
  
  describe '#relay' do
    
    let(:ta) { described_class.new(demuxer, muxer) }
    
    let(:event_one) { "#{Time.now.to_i}|some value|some other value" }
    
    let(:event_two) { "#{Time.now.to_i + 1}|some value 2|some other value 2" }
    
    before(:each) do
      @ios[0].puts event_one
      @ios[0].flush
      @ios[2].puts event_two
      @ios[2].flush
      @ios[0].rewind
      @ios[2].rewind
    end
    
    it 'relays input values to the observers defaults to 1' do
      ta.relay
      expect(outputs.map(&:first)).to eql(0.upto(outputs.size - 1).map { [event_one] })
    end
    
    it 'relays at most the number of input values to observers sepcified in the argument' do
      ta.relay(2)
      expect(outputs.map(&:first)).to eql(0.upto(outputs.size - 1).map { [event_one, event_two] })
    end
    
  end
  
end
