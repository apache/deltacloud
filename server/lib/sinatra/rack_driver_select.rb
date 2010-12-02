class RackDriverSelect

  def initialize(app, opts={})
    @app = app
    @opts = opts
  end

  def call(env)
    original_driver = Thread.current[:driver]
    new_driver = extract_driver(env)
    Thread.current[:driver] = new_driver if new_driver
    @app.call(env)
  ensure
    Thread.current[:driver] = original_driver
  end

  def extract_driver(env)
    driver_name = env['HTTP_HEADERS'].match(/X\-Deltacloud\-Driver:(\w+)/i).to_a
    return driver_name[1] if driver_name[1]
  end

end
