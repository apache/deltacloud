
module DriverHelper

  def driver
    load "drivers/#{DRIVER}.rb"
    @driver ||= eval( "Drivers::" + DRIVER.to_s.camelcase ).new
  end

  def catch_auth
    begin
      yield
    rescue Drivers::AuthException => e
      authenticate_or_request_with_http_basic() do |n,p|
      end
    end
  end

end
