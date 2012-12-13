require 'rubygems'
require 'require_relative' if RUBY_VERSION < '1.9'
require_relative 'common.rb'
require 'socket'
require 'timeout'
require 'rest-client'

def is_port_open?(ip, port)
  begin
    Timeout::timeout(1) do
      begin
        s = TCPSocket.new(ip, port)
        s.close
        return true
      rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH
        return false
      end
    end
  rescue Timeout::Error
  end
  return false
end

def wait_for_port_open(port)
  retries = 5
  begin
    raise unless is_port_open?('127.0.0.1', port)
    true
  rescue
    sleep(1) && retry if (retries-=1) != 0
    false
  end
end

def kill_process(pid)
  Process.kill('TERM', pid) rescue ''
  # Die!
  Process.kill('KILL', pid) rescue ''
end

describe "deltacloudd" do

  before do
    @pids ||= []
  end

  it 'starts the deltacloud server gracefully' do
    pid = Process.fork
    if pid.nil? then
      Dir.chdir(File.join(File.dirname(__FILE__), '..', '..'))
      exec("./bin/deltacloudd -i mock -p 3011")
    else
      Process.detach(pid) && @pids << pid
      wait_for_port_open(3011).must_equal true
      RestClient.get('http://localhost:3011/api').code.must_equal 200
      kill_process(pid)
      is_port_open?('127.0.0.1', 3011).must_equal false
    end
  end

  it 'starts the deltacloud server gracefully with multiple frontends' do
    pid = Process.fork
    if pid.nil? then
      Dir.chdir(File.join(File.dirname(__FILE__), '..', '..'))
      exec("./bin/deltacloudd -i mock -f deltacloud,cimi,ec2 -p 3011")
    else
      Process.detach(pid) && @pids << pid
      wait_for_port_open(3011).must_equal true
      RestClient.get('http://localhost:3011/api').code.must_equal 200
      RestClient.get('http://localhost:3011/cimi/cloudEntryPoint').code.must_equal 200
      kill_process(pid)
      is_port_open?('127.0.0.1', 3011).must_equal false
    end
  end

  it 'starts the deltacloud server gracefully when using webrick' do
    pid = Process.fork
    if pid.nil? then
      Dir.chdir(File.join(File.dirname(__FILE__), '..', '..'))
      exec("./bin/deltacloudd -w -i mock -p 3011")
    else
      Process.detach(pid) && @pids << pid
      wait_for_port_open(3011).must_equal true
      RestClient.get('http://localhost:3011/api').code.must_equal 200
      kill_process(pid)
      is_port_open?('127.0.0.1', 3011).must_equal false
    end
  end

  it 'lists the available drivers' do
    Dir.chdir(File.join(File.dirname(__FILE__), '..', '..'))
    output = `./bin/deltacloudd -l`
    output.must_include 'Available drivers'
    output.must_include 'mock'
  end

  after do
    @pids.map { |pid| kill_process(pid) }
  end

end
