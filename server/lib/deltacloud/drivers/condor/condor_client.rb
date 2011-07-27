# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.  The
# ASF licenses this file to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance with the
# License.  You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  See the
# License for the specific language governing permissions and limitations
# under the License.

require 'pp'
require 'nokogiri'
require 'etc'
require 'tempfile'
require 'yaml'
require 'time'
require 'deltacloud/drivers/condor/ip_agents/default'
require 'deltacloud/drivers/condor/ip_agents/confserver'

module CondorCloud

  class CondorAddress
    attr_accessor :ip
    attr_accessor :mac

    def initialize(opts={})
      @ip, @mac = opts[:ip], opts[:mac]
    end
  end


  class DefaultExecutor

    CONDOR_Q_CMD = ENV['CONDOR_Q_CMD'] || "condor_q"
    CONDOR_RM_CMD = ENV['CONDOR_RM_CMD'] || "condor_rm"
    CONDOR_SUBMIT_CMD = ENV['CONDOR_SUBMIT_CMD'] || 'condor_submit'

    # This directory needs to be readable for user running Deltacloud API
    CONDOR_CONFIG = ENV['CONDOR_CONFIG'] || 'config/condor.yaml'

    attr_accessor :ip_agent
    attr_reader :config

    # You can use your own IP agent using :ip_agent option.
    # IPAgent should have parent class set to 'IPAgent' and implement all
    # methods from this class. You can pass options to ip_agent using
    # :ip_agent_args hash.
    #
    def initialize(opts={}, &block)
      load_config!
      if opts[:ip_agent]
        @ip_agent = opts[:ip_agent]
      else
        default_ip_agent = CondorCloud::const_get(@config[:default_ip_agent])
        @ip_agent = default_ip_agent.new(:config => @config)
      end
      yield self if block_given?
      self
    end

    def load_config!
      @config = YAML::load(File.open(CONDOR_CONFIG))
    end

    # List instances using ENV['CONDOR_Q_CMD'] command.
    # Retrieve XML from this command and parse it using Nokogiri. Then this XML
    # is converted to CondorCloud::Instance class
    #
    # @opts - This Hash can be used for filtering instances using :id => 'instance_id'
    #
    def instances(opts={})
      bare_xml = Nokogiri::XML(`#{CONDOR_Q_CMD} -xml`)
      parse_condor_q_output(bare_xml, opts)
    end

    # List all files in ENV['STORAGE_DIRECTORY'] or fallback to '/home/cloud/images'
    # Convert files to CondorCloud::Image class
    #
    # @opts - This Hash can be used for filtering images using :id => 'SHA1 of
    # name'
    #
    def images(opts={})
      Dir["#{@config[:image_storage]}/*"].collect do |file|
        next unless File::file?(file)
        next unless File::readable?(file)
        image = Image.new(
          :name => File::basename(file).downcase.tr('.', '-'),
          :owner_id => Etc.getpwuid(File.stat(file).uid).name,
          :description => file
        )
        next if opts[:id] and opts[:id]!=image.id
        image
      end.compact
    end

    # Launch a new instance in Condor cloud using ENV['CONDOR_SUBMIT_CMD'].
    # Return CondorCloud::Instance.
    #
    # @image  - Expecting CondorCloud::Image here
    # @hardware_profile - Expecting CondorCloud::HardwareProfile here
    #
    # @opts - You can specify additional parameters like :name here
    #         You can set additional parameters for libvirt using :user_data
    #         specified in JSON format.
    #
    #         Parameters are:
    #
    #         { 'bridge_dev' : 'br0' }
    #         { 'smbios' : 'sysinfo' }
    #         { 'vnc_port' : '5900' }
    #         { 'vnc_ip' : '0.0.0.0' }
    #         { 'features' : ['acpi', 'apic', 'pae'] }
    #         { 'sysinfo' : { 'bios_vendor' : 'Lenovo', 'system_manufacturer' : 'Virt', 'system_vendor' : 'IBM' } }
    #
    #         Of course you can combine them as you want, like (:user_data => "{ 'bridge_dev' : 'br0', 'vnc_ip' : 127.0.0.1 }")
    #
    def launch_instance(image, hardware_profile, opts={})
      raise "Image object must be not nil" unless image
      raise "HardwareProfile object must be not nil" unless hardware_profile
      opts[:name] ||= "i-#{Time.now.to_i}"

      # This needs to be determined by the mac/ip translation stuff.
      # We need to call into it and have it return these variables, or at least the MAC if not the IP.
      mac_addr = @ip_agent.find_free_mac
      ip_addr = @ip_agent.find_ip_by_mac(mac_addr) if mac_addr && !mac_addr.empty?

      libvirt_xml = "+VM_XML=\"<domain type='kvm'>
        <name>{NAME}</name>
        <memory>#{hardware_profile.memory.value.to_i * 1024}</memory>
        <vcpu>#{hardware_profile.cpu.value}</vcpu>
        <os>
          <type arch='x86_64'>hvm</type>
          <boot dev='hd'/>
          <smbios mode='sysinfo'/>
        </os>
        <sysinfo type='smbios'>
          <system>
            <entry name='manufacturer'>#{opts[:config_server_address]}</entry>
            <entry name='product'>#{opts[:uuid]}</entry>
            <entry name='serial'>#{opts[:otp]}</entry>
          </system>
        </sysinfo>
        <features>
          <acpi/><apic/><pae/>
        </features>
        <clock offset='utc'/>
        <on_poweroff>destroy</on_poweroff>
        <on_reboot>restart</on_reboot>
        <on_crash>restart</on_crash>
        <devices>
          <disk type='file' device='disk'>
            <source file='{DISK}'/>
            <target dev='vda' bus='virtio'/>
            <driver name='qemu' type='qcow2'/>
          </disk>
          <interface type='bridge'>
            #{"<mac address='" + mac_addr + "'/>" if mac_addr && !mac_addr.empty?}
            <source bridge='#{@config[:default_bridge]}'/>
          </interface>
          <graphics type='vnc' port='#{@config[:vnc_listen_port]}' autoport='yes' keymap='en-us' listen='#{@config[:vnc_listen_ip]}'/>
        </devices>
      </domain>\"".gsub(/(\s{2,})/, ' ').gsub(/\>\s\</, '><')

      # I use the 2>&1 to get stderr and stdout together because popen3 does not support
      # the ability to get the exit value of the command in ruby 1.8.
      pipe = IO.popen("#{CONDOR_SUBMIT_CMD} 2>&1", "w+")
      pipe.puts "universe=vm"
      pipe.puts "vm_type=kvm"
      pipe.puts "vm_memory=#{hardware_profile.memory.value}"
      pipe.puts "request_cpus=#{hardware_profile.cpu.value}"
      pipe.puts "vm_disk=#{image.description}:null:null"
      pipe.puts "executable=#{image.description}"
      pipe.puts "vm_macaddr=#{mac_addr}"

      # Only set the ip if it is available, and this should depend on the IP mapping used.
      # With the fixed mapping method we know the IP address right away before we start the
      # instance, so fill it in here.  If it is not set I think we should set it to an empty
      # string and we'll fill it in later using a condor tool to update the job.
      pipe.puts "+vm_ipaddr=\"#{ip_addr}\""
      pipe.puts '+HookKeyword="CLOUD"'
      pipe.puts "+Cmd=\"#{opts[:name]}\""
      # Really the image should not be a full path to begin with I think..
      pipe.puts "+cloud_image=\"#{File.basename(image.description)}\""
      pipe.puts libvirt_xml
      pipe.puts "queue"
      pipe.puts ""
      pipe.close_write
      out = pipe.read
      pipe.close

      if $? != 0
        raise "Error starting VM in condor_submit: #{out}"
      end

      bare_xml = Nokogiri::XML(`#{CONDOR_Q_CMD} -xml`)
      parse_condor_q_output(bare_xml, :name => opts[:name])
    end

    def destroy_instance(instance_id)
      bare_xml = Nokogiri::XML(`#{CONDOR_Q_CMD} -xml`)
      cluster_id = (bare_xml/'/classads/c/a[@n="GlobalJobId"]/s').collect do |id|
        id.text.split('#')[1] if id.text.split('#').last==instance_id
      end.compact.first
      `#{CONDOR_RM_CMD} #{cluster_id}`
    end

    # List hardware profiles available for Condor.
    # Basically those profiles are static 'small', 'medium' and 'large'
    #
    # Defined as:
    #
    #    when { :memory => '512', :cpus => '1' } then 'small'
    #    when { :memory => '1024', :cpus => '2' } then 'medium'
    #    when { :memory => '2047', :cpus => '4' } then 'large'
    #
    # @opts - You can filter hardware_profiles using :id
    #
    def hardware_profiles(opts={})
      return [
        { :name => 'small', :cpus => 1, :memory => 512 },
        { :name => 'medium', :cpus => 2, :memory => 1024 },
        { :name => 'large', :cpus => 4, :memory => 2048 }
      ]
    end

    private

    def convert_image_name_to_id(name)
      Digest::SHA1.hexdigest(name).to_s
    end

    def parse_condor_q_output(bare_xml, opts={})
      inst_array = []
      (bare_xml/"/classads/c").each do |c|
        unless opts[:id].nil?
          next unless (c/'a[@n="GlobalJobId"]/s').text.strip.split('#').last==opts[:id]
        end
        unless opts[:name].nil?
          next unless (c/'a[@n="Cmd"]/s').text.strip==opts[:name]
        end
        # Even with the checks above this can still fail because there may be other condor jobs
        # in the queue formatted in ways we don't know.
        begin
          inst_array << Instance.new(
            :id => (c/'a[@n="GlobalJobId"]/s').text.strip.split('#').last,
            :name => (c/'a[@n="Cmd"]/s').text.strip,
            :state => Instance::convert_condor_state((c/'a[@n="JobStatus"]/i').text.to_i),
            :public_addresses => [
              CondorAddress.new(:mac => (c/'a[@n="JobVM_MACADDR"]/s').text, :ip => (c/'a[@n="vm_ipaddr"]/s').text)
            ],
            :instance_profile => HardwareProfile.new(:hwp_memory => (c/'a[@n="JobVMMemory"]/i').text, :hwp_cpu => (c/'a[@n="JobVM_VCPUS"]/i').text),
            :owner_id => (c/'a[@n="User"]/s').text,
            :image_id => convert_image_name_to_id(File::basename((c/'a[@n="VMPARAM_vm_Disk"]/s').text.split(':').first).downcase.tr('.', '-')),
            :realm => Realm.new(:id => (c/'a[@n="JobVMType"]/s').text),
            :launch_time => Time.at((c/'a[@n="JobStartDate"]/i').text.to_i)
          )
        rescue Exception => e
          puts "Caught exception (may be safe to ignore if other jobs present): #{e}"
          puts e.message
          puts e.backtrace
          # Be nice to log something here in case we start getting silent failures.
        end
      end
      inst_array
    end

  end
end
