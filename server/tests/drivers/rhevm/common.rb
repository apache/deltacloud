# Make less noise to console
ENV['RACK_ENV'] ||= 'test'

require 'vcr'
require 'pp'
require 'time'

# Credentials used to access RHEV-M server
#
# NOTE: If these are changed, the VCR fixtures need to be re-recorded
#
def credentials
  {
    :user => 'vdcadmin@rhev.lab.eng.brq.redhat.com',
    :password => '123456',
    :provider => 'https://rhev30-dc.lab.eng.brq.redhat.com:8443/api;645e425e-66fe-4ac9-8874-537bd10ef08d'
  }
end

module TestPooler
  # This method will pool the resource until condition is true
  # Will raise 'Timeout' when it reach retry count
  #
  # default opts[:retries] => 10
  # default opts[:time_between_retry] => 10 (seconds)
  # default opts[:timeout] => 60 (seconds) -> single request timeout
  #
  # opts[:before] => Proc -> executed 'before' making each request
  # opts[:after] => Proc -> executed 'after' making each request
  #
  def wait_for!(driver, opts={}, &block)
    opts[:retries] ||= 10
    opts[:time_between_retry] ||= 10
    opts[:timeout] ||= 60
    opts[:method] ||= self.class.name.downcase.to_sym
    opts[:retries].downto(0) do |r|
      result = begin
        timeout(opts[:timeout]) do
          if opts[:before]
            new_instance = opts[:before].call(r) { driver.send(opts[:method], :id => self.id) }
          else
            new_instance = driver.send(opts[:method], :id => self.id)
          end
          ((yield new_instance) == true) ? new_instance : false
        end
      rescue Timeout::Error
        false
      ensure
        opts[:after].call(r) if opts[:after]
      end
      return result unless result == false
      sleep(opts[:time_between_retry])
    end
    raise Timeout::Error
  end
end

class Instance; include TestPooler; end
class Image; include TestPooler; end

VCR.configure do |c|
  # NOTE: Empty this directory before re-recording
  c.cassette_library_dir = File.join(File.dirname(__FILE__), 'fixtures')
  c.hook_into :webmock
  # Set this to :new_epizodes when you want to 're-record'
  c.default_cassette_options = { :record => :none }
end

# Some test scenarios use .wait_for! method that do multiple retries
# for requests. We need to deal with that passing a Proc that use
# different cassette for each request

def record_retries(name='')
  {
    :before => Proc.new { |r, &block|
      VCR.use_cassette("#{__name__}-#{name.empty? ? '' : "#{name}-"}#{r}", &block)
    }
  }
end
