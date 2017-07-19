root = File.expand_path(__dir__)
Gem::Specification.new do |spec|
  spec.name           = 'lib-adt'
  spec.version        = '0.0.1'
  spec.authors        = ['David Faber']
  spec.email          = ['david@1bios.co']
  spec.summary        = 'Algebraic data types'

  spec.files          = Dir[File.join(root, 'lib/**/*')] +
                        Dir[File.join(root, 'spec/**/*')] +
                        [
                          'Gemfile',
                          'Rakefile',
                          'README.md',
                          'lib-adt.gemspec'
                        ]
  spec.test_files     = spec.files.grep(%r{^spec/})
  spec.require_paths  = ['lib']

  spec.required_ruby_version = '>= 2'

  spec.add_development_dependency 'rake', '~> 10.4.0'
  spec.add_development_dependency 'rspec', '~> 3.4.0'
end
