require 'sinatra'
require 'rubygems'

set :environment => :production
set :raise_errors => false
set :run => false

#log = File.new("log/deltacloud.log", "a+")
#STDOUT.reopen(log)
#STDERR.reopen(log)

require 'server.rb'
run Sinatra::Application
