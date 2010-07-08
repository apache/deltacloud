
module DriverHelper

  def driver
    @driver ||= Drivers::EC2.new
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
