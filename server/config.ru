require 'rubygems'
require 'sinatra'

$:.unshift File.join(File.dirname(__FILE__), '.')

require 'server.rb'
run Sinatra::Application
