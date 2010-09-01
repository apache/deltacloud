require 'fileutils'
require 'rake'
require 'find'

Given /^I have a clean (.+) directory$/ do |dir|
  FileUtils.rm_rf dir  
end

When /^I run a '(\w+)' task$/ do |task|
  @rake = Rake::Application.new
 Rake.application = @rake
 load "Rakefile"
 @task = Rake::Task[task]
 @task.invoke
end

Then /^I should see a (\w+) file inside (\w+) directory$/ do |ext, dir|
  Dir["#{dir}/deltacloud-*.#{ext}"].size.should == 2
end
