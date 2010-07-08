
class BaseModel

  def initialize(init=nil)
    if ( init )
      @id=init[:id]
      init.each{|k,v|
        self.send( "#{k}=", v ) if ( self.respond_to?( "#{k}=" ) )
      }
    end
  end

  def id
    @id
  end

end
