
module DriverHelper

  def driver
    load "#{DRIVER_CLASS_NAME.underscore}.rb"
    @driver ||= eval( DRIVER_CLASS_NAME ).new
  end

  def catch_auth
    begin
      yield
    rescue DeltaCloud::AuthException => e
      authenticate_or_request_with_http_basic() do |n,p|
      end
    end
  end

end
