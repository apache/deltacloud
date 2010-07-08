
class BaseModel
  def initialize(init=nil)
    if ( init )
      self.resource_id=init[:id]
      init.each{|k,v|
        self.send( "#{k}=", v ) if ( self.respond_to?( "#{k}=" ) )
      }
    end
  end
end
