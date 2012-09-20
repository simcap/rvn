spec = Gem::Specification.new do |s| 
  s.name = 'rvn'
  s.version = 0.1
  s.author = 'Simon Caplette'
  s.homepage = 'https://github.com/simcap/raven'
  s.platform = Gem::Platform::RUBY
  s.summary = 'Ruby over the maven command line'
  s.files = %w(bin/rvn raven.rb)
  s.bindir = 'bin'
  s.executables << 'rvn'
  s.add_runtime_dependency('rainbow')
  s.add_runtime_dependency('nokogiri')
  s.add_runtime_dependency('httparty')
  s.add_runtime_dependency('terminal-table')
end
