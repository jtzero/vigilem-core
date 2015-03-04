# -*- encoding: utf-8 -*-
require './lib/vigilem/core/version'

Gem::Specification.new do |s|
  s.name          = 'vigilem-core'
  s.version       = Vigilem::Core::VERSION
  s.platform      = Gem::Platform::RUBY
  s.summary       = 'Core components for Vigilem handlers and Converters'
  s.description   = 'Core components for Vigilem handlers and Converters'
  s.authors       = ['jtzero']
  s.email         = 'jtzero511@gmail'
  s.homepage      = 'http://rubygems.org/gems/vigilem-core'
  s.license       = 'MIT'
  
  if s.respond_to? :metadata
    s.metadata = { 
        "source_code" => "hg@bitbucket.com/jtzero/vigilem-core",
        "project_page" => "http://bitbucket.com/jtzero/vigilem-core",
        "bug_tracker" => "http://bitbucket.com/jtzero/vigilem-core/issues"
      }
  end
  
  s.add_dependency 'vigilem-support'
  s.add_dependency 'hashery'
  s.add_dependency 'thread_safe'
  
  s.add_development_dependency 'yard'
  s.add_development_dependency 'bundler', '~> 1.7'
  s.add_development_dependency 'rake', '~> 10.0'
  s.add_development_dependency 'rspec', '~> 3.1'
  s.add_development_dependency 'rspec-given'
  s.add_development_dependency 'turnip'
  s.add_development_dependency 'guard-rspec'
  
  s.files         = Dir['{lib,spec,ext,test,features,bin}/**/**']
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})
  s.require_paths = ['lib']
end
