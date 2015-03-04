require 'spec_helper'

require 'tempfile'

require 'vigilem/support/core_ext'

require 'vigilem/core/multiplexer'

describe Vigilem::Core::Multiplexer do
  
  before(:each) do
    @out = Tempfile.new('out')
    @ios = [Tempfile.new('foo'), Tempfile.new('bar'),
                      Tempfile.new('fizz'), Tempfile.new('buzz')]
  end
  
  class MultiplexerHost
    include Vigilem::Core::Multiplexer
    def initialize(inpts, out=nil)
      initialize_multiplexer(inpts, out)
    end
    
  end
  
  after(:each) do
    @out.respond(:close)
    @ios.each {|io| io.respond.close }
  end
  
  let(:out) { @out }
  
  let(:io_objs) { @ios[0..1] }
  
  describe '::initialize' do
    
    it 'updates inputs array' do
      expect(MultiplexerHost.new(io_objs.sample(2), out).inputs).to match [duck_type(:fileno)]  * 2
    end
    
  end
  
  context 'post init' do
    
    let(:plex) { MultiplexerHost.new(@ios, out) }
    
    describe '#ready?' do
      
      context 'all ready' do
        
        it 'returns the ready files' do
          expect(plex.ready?).to match(@ios)
        end
      end
      context 'some not ready' do
        let(:rw) { IO.pipe }
        
        let(:pipes) do 
          rw.last << 'ready'
          [IO.pipe, *rw].flatten
        end
        
        let(:mplex) { MultiplexerHost.new(pipes) }
        
        it 'returns the ready files' do
          #expect(mplex.ready?).to eql([rw]) #hangs
          expect(mplex.ready?.first).to eql(rw.first)
        end
      end
      
    end
    
    context 'private' do
      describe '#recursive_check' do
        it %q<checks to make sure an input on the multiplexer isn't the same as the output> do
          a = []
          plex.inputs << a
          plex.output = a
          expect do
            plex.send(:recursive_check)
          end.to raise_error(ArgumentError)
        end
      end
    end
    
    describe '::add_inputs' do
      it %q<raises error if an input and matches the output> do
        expect do
          plex.add_inputs(plex.output)
        end.to raise_error(ArgumentError)
      end
      
      it %q<runs a uniq! to prevent duplicate items in the inputs> do
        ipt = plex.inputs.first
        expect(plex.add_inputs(ipt).count(ipt)).to eql(1)
      end
    end
    
    describe '#mux' do
      
      before(:each) do
        allow(plex).to receive(:sweep).with(3) { [1,2,3] }
      end
      
      it 'takes the return from sweep and adds it to #out' do
        plex.mux(3)
        expect((f = File.open(plex.out)).each_char.to_a).to eql(%w(1 2 3))
        f.close
      end
      
    end
    
  end
end
