
module DriverHelper

  def driver
    @driver ||= Drivers::EC2.new
  end

end
