Gem::Specification.new do |gem|
  gem.name = 'sass-extractor'
  gem.version = '0.1.0'
  gem.authors = ['Daniel Brockman']
  gem.email = ['daniel@gointeractive.se']
  gem.summary = 'Extract the contents of Sass files.'
  gem.homepage = 'http://github.com/dbrock/sass-extractor'
  gem.files = ['lib/sass-extractor.rb']
  gem.add_dependency('sass', '~> 3.1.1')
end
