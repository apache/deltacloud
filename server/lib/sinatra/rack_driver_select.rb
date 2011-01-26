module Rack
  class DriverSelect

    def initialize(app, opts={})
      @app = app
      @opts = opts
    end

    HEADER_TO_ENV_MAP = {
      'HTTP_X_DELTACLOUD_DRIVER' => :driver,
      'HTTP_X_DELTACLOUD_PROVIDER' => :provider
    }
    
    def call(env)
      original_settings = { }
      HEADER_TO_ENV_MAP.each do |header, name|
        original_settings[name] = Thread.current[name]
        new_setting = extract_header(env, header)
        Thread.current[name] = new_setting if new_setting
      end
      @app.call(env)
    ensure
      original_settings.each { |name, value| Thread.current[name] = value }
    end

    def extract_header(env, header)
      env[header].downcase if env[header]
    end

  end
end
