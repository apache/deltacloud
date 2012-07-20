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

Then /^I should see a (\d+) (\w+) file inside (\w+) directory$/ do |count, ext, dir|
  Dir["#{dir}/deltacloud-*.#{ext}"].size.should == count.to_i
end
