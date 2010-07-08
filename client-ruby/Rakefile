
require 'spec/rake/spectask'


desc "Run all examples"
Spec::Rake::SpecTask.new('spec') do |t|
  t.spec_files = FileList['specs/**/*_spec.rb']
end

desc "Setup Fixtures"
task 'fixtures' do
  FileUtils.rm_rf( File.dirname( __FILE__ ) + '/specs/data' )
  FileUtils.cp_r( File.dirname( __FILE__ ) + '/specs/fixtures', File.dirname( __FILE__ ) + '/specs/data' )
end

desc "Clean Fixtures"
task 'fixtures:clean' do
  FileUtils.rm_rf( File.dirname( __FILE__ ) + '/specs/data' )
end
