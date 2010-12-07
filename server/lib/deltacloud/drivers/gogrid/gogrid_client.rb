require 'digest/md5'
require 'cgi'
require 'open-uri'

class GoGridClient

  def initialize(server='https://api.gogrid.com/api',
                 apikey='YOUR API KEY',
                 secret='YOUR SHARED SECRET', 
                 format='json',
                 version='1.6')
    @server = server
    @secret = secret
    @default_params = {'format'=>format, 'v'=>version,'api_key' => apikey}
  end    
  
  def getRequestURL(method,params)
    requestURL = @server+'/'+method+'?'
  	call_params = @default_params.merge(params)
  	call_params['sig']=getSignature(@default_params['api_key'],@secret)
  	requestURL = requestURL+encode_params(call_params)
  end
  
  def getSignature(key,secret)
    Digest::MD5.hexdigest(key+secret+"%.0f"%Time.new.to_f)
  end
  
  def sendAPIRequest(method,params={})
    open(getRequestURL(method,params)).read
  end

  def request(method, params={}, version=nil)
    if version
      @default_params['v'] = version
    else
      @default_params['v'] = '1.5'
   end
    request = sendAPIRequest(method, params)
    JSON::parse(request)
  end
  
  def encode_params(params)
    params.map {|k,v| "#{CGI.escape(k.to_s)}=#{CGI.escape(v.to_s)}" }.join("&")
  end
    
end
