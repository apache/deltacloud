require 'rubygems'
require 'colored'
require 'progress_bar'
require 'rest-client'
require 'nokogiri'
require 'net/ssh'
require 'net/scp'
require 'optparse'
require 'socket'
require 'timeout'



options = {}
optparse = OptionParser.new do |opts|
  opts.banner = <<BANNER
Usage:
cloudexec -f file [options]

Options:
BANNER
  opts.on( '-f', '--file FILE', 'Script to execute in instance') { |script| ENV["DC_SCRIPT_NAME"] = script }
  opts.on( '-d', '--deltacloud-url URL', 'Deltacloud API URL (default: http://localhost:3001/api)') { |script| ENV["DC_URL"] = script }
  opts.on( '-i', '--image IMAGE', 'Image to use') { |p| ENV["DC_IMAGE"] = p }
  opts.on( '-u', '--username USERNAME', 'Deltacloud username') { |p| ENV["DC_USERNAME"] = p }
  opts.on( '-r', '--instance-user USERNAME', 'Instance user. (default: root)') { |p| ENV["DC_INSTANCE_USERNAME"] = p }
  opts.on( '-p', '--password PASSWORD', 'Deltacloud password') { |p| ENV["DC_PASSWORD"] = p }
  opts.on( '-s', '--profile HARDWARE_PROFILE', 'Hardware profile to use (default: t1.micro)') { |p| ENV["DC_PROFILE"] = p }
  opts.on( '-h', '--help', '') { options[:help] = true }
end

optparse.parse!

if options[:help]
 puts optparse
 exit(0)
end

unless ENV['DC_SCRIPT_NAME']
  puts "ERROR: You need to specify a script name to be executed on instance".red
  exit 1
end

ENV['DC_INSTANCE_USERNAME'] ||= 'ec2-user'
ENV['DC_URL'] ||= 'http://localhost:5000/api'

config = {
  :username => ENV['DC_USERNAME'] || '',
  :password => ENV['DC_PASSWORD'] || '',
  :image_id => ENV['DC_IMAGE'] || 'ami-8e1fece7',
  :profile => ENV['DC_PROFILE'] || 't1.micro',
  :name => "inst-#{Time::now.to_i}"
}

auth = { :authorization => "Basic " + ["#{config[:username]}:#{config[:password]}"].pack("m0").gsub(/\n/,'') }
client = RestClient::Resource.new(ENV['DC_URL'])

puts "[INFO] Creating new #{config[:profile]} instance named '#{config[:name]}' using #{config[:image_id]} image...".green
bar = ProgressBar.new(100, :bar, :percentage)

# Prepare SSH key for instance
#

# Create SSH key
key = Nokogiri::XML(client['keys'].post({
  :name => "key-#{config[:name]}"
}, auth))

# Save SSH key to local storage
key_file = File::join("/var/tmp/deltacloud-exec/#{(key/'key/@id')}.pem")
FileUtils::mkdir_p(File::dirname(key_file))
File::open(key_file, "w") do |f|
  (key/'pem').text.split("\n").each do |line|
    f.puts(line.strip) if line.strip.size > 0
  end
end
FileUtils.chmod 0600, key_file
bar.increment! 10

#
#########

# Create new firewall rule for the instance
#

firewall = client['firewalls'].post({
  :name => "firewall-#{config[:name]}",
  :description => "SSH permissive firewall"
}, auth)
bar.increment! 10

# Add rule to allow SSH to the firewall
client["firewalls/firewall-#{config[:name]}/rules"].post({
  :protocol => 'tcp',
  :from_port => '22',
  :to_port => '22',
  :ip_address => '0.0.0.0/0'
}, auth)
bar.increment! 10

#
########

# Launch instance
#

instance = client['instances'].post({
  :name => config[:name],
  :image_id => config[:image_id],
  :hwp_id => config[:profile],
  :keyname => "key-#{config[:name]}",
  :firewalls1 => "firewall-#{config[:name]}"
}, auth)

bar.increment! 10

#
#########

# Pool until instance will be in running state

incrementer = 20
20.times do
  instance = client["instances/#{Nokogiri::XML(instance)/'instance/@id'}"].get(auth)
  bar.increment! 1
  incrementer -= 1
  break if (Nokogiri::XML(instance)/'instance/state').first.text == 'RUNNING'
  sleep(3)
end
bar.increment! incrementer

#
########

# Pool until SSH port is not open
#
instance_ip_address = (Nokogiri::XML(instance)/'instance/public_addresses/address').first.text
incrementer = 20
20.times do
  begin
    Timeout::timeout(1) do
      begin
        s = TCPSocket.new(instance_ip_address, 22)
        s.close
        break
      rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH
        sleep(2)
        bar.increment! 1
        incrementer -= 1
        next
      end
    end
  rescue Timeout::Error
    sleep(2)
    bar.increment! 1
    incrementer -= 1
  end
end
bar.increment! incrementer

#########

# Copy script via SCP to the instance
#

output = ""

Net::SSH.start(instance_ip_address, ENV['DC_INSTANCE_USERNAME'], { :keys => [ key_file ]}) do |session|
  session.scp.upload! File::expand_path(ENV['DC_SCRIPT_NAME']), "/tmp"
  output = session.exec!("sh /tmp/#{File::basename(ENV['DC_SCRIPT_NAME'])}")
end

bar.increment! 20

puts "\t====== OUTPUT ======\n\n#{output}\n\n====================\n"
puts "[INFO] Cleaning up instance...".green

# Cleanup

bar = ProgressBar.new(100, :bar, :percentage)

result = client["instances/#{(Nokogiri::XML(instance)/'instance/@id').first.text}"].delete(auth)
if result.status != 204
  puts "Unable to remove instance #{config[:name]}. Please delete it manually."
  exit
else
  bar.increment! 30
end

result = client["keys/#{(Nokogiri::XML(key)/'key/@id').first.text}"].delete(auth)
if result.status != 204
  puts "Unable to remove key key-#{config[:name]}. Please delete it manually."
  exit
else
  FileUtils.rm key_file
  bar.increment! 30
end

result = client["firewalls/#{(Nokogiri::XML(firewall)/'firewall/@id').first.text}"].delete(auth)
if result.status != 204
  puts "Unable to remove firewall firewall-#{config[:name]}. Please delete it manually."
  exit
else
  bar.increment! 40
end
