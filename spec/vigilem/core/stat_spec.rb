require 'vigilem/core/stat'

# @TODO cleanup commented out parts
describe Vigilem::Core::Stat do
  
  context 'class level' do
    describe 'initialize' do
      it 'setup class level platform masks' do
        arg = described_class.new('FakeInputSystem', 'fake_input_system_gem', :platforms => /.+/ )
        expect(arg.platform_masks).to eql([/.+/])
      end
      
      it 'will have more granular proc check than just platforms' do
        check = lambda { 'test' }
        arg = described_class.new('FakeInputSystem', 'fake_input_system_gem',  :platforms => /.+/, &check)
        expect(arg.send :api_check).to eql(check)
      end
      
      describe '::api_check?' do
        it 'will run the api check and "convert" the result to [TrueClass || FalseClass]' do
          arg = described_class.new('FakeInputSystem', 'fake_input_system_gem',  :platforms => /.+/) { 'test' }
          expect(arg.api_check?).to be_truthy
        end
      end
      
      describe '::available_on?' do
        it 'will test the platforms set in new against a given String' do
          arg = described_class.new('FakeInputSystem', 'fake_input_system_gem',  :platforms => /darwin/)
          expect(arg.available_on?('darwin')).to be_truthy
        end
      end
        #alias_method :is_available_on?, :available_on?
      
      describe '::available?' do
        let(:check) { lambda { true } }
        
        context 'platforms match' do
          
          it 'will call check' do
            arg = described_class.new('FakeInputSystem', 'fake_input_system_gem',  :platforms => /.+/, &check)
            expect(check).to receive(:call).and_return(true)
            arg.available?
          end
          
          it 'available? will be true' do
            arg = described_class.new('FakeInputSystem', 'fake_input_system_gem',  :platforms => /.+/, &check)
            expect(arg.available?).to be_truthy
          end
        end
        context %q<platforms don't match> do
          
          it '#available? will be false' do
            arg = described_class.new('FakeInputSystem', 'fake_input_system_gem',  :platforms => /1234/, &check)
            expect(arg.available?).to be_falsey
          end
        end
        
      end
      
    end
  end
  
end
