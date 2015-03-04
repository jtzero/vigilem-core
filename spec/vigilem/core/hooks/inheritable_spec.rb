require 'spec_helper'

require 'vigilem/core/hooks'

require 'vigilem/support/lazy_simple_delegator'

require 'vigilem/support/system'

require 'vigilem/core'

describe Vigilem::Core::Hooks::Inheritable do
  subject { Vigilem::Core::Device }
  
  context 'will inherit hooks' do
    it 'will have at least one callback from AbstractDevice' do
      expect(subject.hooks.find {|hook| hook.name == :after_init }.owner).to eql(Vigilem::Core::AbstractDevice)
    end
  end
end