# defines a given that takes a block and argument so that the argument given can be used as the description and
# retrieved by given_value, essentially making bad tests
RSpec::Core::ExampleGroup.define_singleton_method(:given) do |arg, &example_group_block|
  thread_data = RSpec.thread_local_metadata
  ret = subclass(self, 'given', arg.to_s, &example_group_block).tap do |child|
    children << child
  end
  ret.send(:define_method, :given_value) do
    arg
  end
  ret.new
end