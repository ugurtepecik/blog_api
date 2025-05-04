Gem::Specification.new do |spec|
  spec.name          = 'typedfiles'
  spec.version       = '0.1.0'
  spec.authors       = ['Ugur Tepecik']
  spec.email         = ['tepeciku@gmail.com']

  spec.summary       = 'Generate Ruby files with strict Sorbet type annotations'
  spec.description   = 'CLI tool to create Ruby service files with typed: strict comment and class skeletons'
  spec.homepage      = 'https://github.com/your_github/typedfiles'
  spec.license       = 'MIT'

  spec.files         = Dir['lib/**/*', 'bin/*', 'LICENSE', 'README.md']
  spec.bindir        = 'bin'
  spec.executables   = ['typedfiles']
  spec.require_paths = ['lib']
  spec.metadata['rubygems_mfa_required'] = 'true'
end
