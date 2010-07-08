Gem::Specification.new do |s|
  s.author = 'Red Hat, Inc.'
  s.homepage = "http://www.deltacloud.org"
  s.name = 'deltacloud-client-ruby'
  s.description = %q{Deltacloud REST Client}
  s.version = '0.0.1'
  s.summary = %q{Deltacloud Client}
  s.files = Dir['Rakefile', 'credentials.yml', 'lib/**/*.rb', 'init.rb' ]
  s.test_files= Dir.glob("specs/**/**")
end
