require 'syslog'
require 'lib/sinatra/body_proxy'

class SyslogFile < File

  def initialize
    @log = Syslog.open($0, Syslog::LOG_PID | Syslog::LOG_LOCAL5)
  end

  def write(string)
    @log.warning(string) if string.strip.length > 0
    return string.chars.count
  end

  def info(msg)
    @log.info(msg)
  end

  def err(msg)
    @log.err(msg)
  end

  alias :warning :err

end

# Code bellow was originaly copied from Rack::CommonLogger
# https://raw.github.com/rack/rack/master/lib/rack/commonlogger.rb

module Rack
  # Rack::CommonLogger forwards every request to an +app+ given, and
  # logs a line in the Apache common log format to the +logger+, or
  # rack.errors by default.
  class SyslogLogger

    # Common Log Format: http://httpd.apache.org/docs/1.3/logs.html#common
    # lilith.local - - [07/Aug/2006 23:58:02] "GET / HTTP/1.1" 500 -
    #             %{%s - %s [%s] "%s %s%s %s" %d %s\n} %
    FORMAT = %{%s - %s [%s] "%s %s%s %s" %d %s %0.4f\n}

    def initialize(app, logger=nil)
      @app = app
      @logger = logger || $stdout
    end

    def call(env)
      began_at = Time.now
      status, header, body = @app.call(env)
      header = Utils::HeaderHash.new(header)
      body = Rack::BodyProxy.new(body) { log(env, status, header, began_at) }
      [status, header, body]
    end

    private

    def log(env, status, header, began_at)
      now = Time.now
      length = extract_content_length(header)

      if status.to_s =~ /5(\d{2})/
        method = :err
      else
        method = :info
      end

      logger = @logger || env['rack.errors']
      logger.send(method, FORMAT % [
        env['HTTP_X_FORWARDED_FOR'] || env["REMOTE_ADDR"] || "-",
        env["REMOTE_USER"] || "-",
        now.strftime("%d/%b/%Y %H:%M:%S"),
        env["REQUEST_METHOD"],
        env["PATH_INFO"],
        env["QUERY_STRING"].empty? ? "" : "?"+env["QUERY_STRING"],
        env["HTTP_VERSION"],
        status.to_s[0..3],
        length,
        now - began_at ])
    end

    def extract_content_length(headers)
      value = headers['Content-Length'] or return '-'
      value.to_s == '0' ? '-' : value
    end
  end
end

