require 'vigilem/core/lockable_pipeline_component'

describe Vigilem::Core::LockablePipelineComponent do
  
  class LPCHost
    include Vigilem::Core::LockablePipelineComponent
  end
  
  subject { LPCHost.new }
  
  describe '#semaphore' do
    it 'pulls from #source if available' do
      allow(subject).to receive(:source)
      expect(subject).to receive(:source)
      subject.semaphore
    end
  end
  
end
