require "net/http"
require "net/https"
require "rubygems"
require "json"
require "deltacloud/base_driver"

class RimuHostingClient
  def initialize(credentials ,baseuri = 'https://rimuhosting.com/r')
    @uri = URI.parse(baseuri)
    @service = Net::HTTP.new(@uri.host, @uri.port)
    @service.use_ssl = true
    if(credentials[:password].nil? || credentials[:password] == "")
      @auth = nil
    else
      @auth = "rimuhosting apikey=%s" % [credentials[:password]]  
    end

  end

  def request(resource, data='', method='GET')
    headers = {"Accept" => "application/json", "Content-Type" => "application/json"}
    if(!@auth.nil?)
      headers["Authorization"] = @auth
    end
    r = @service.send_request(method, @uri.path + resource, data, headers)
         puts r.body
    res = JSON.parse(r.body)
    res = res[res.keys[0]]

    if(res['response_type'] == "ERROR" and res['error_info']['error_class'] == "PermissionException")
      raise DeltaCloud::AuthException.new
    end
    res
  end

  def list_images
    request('/distributions')["distro_infos"]
  end

  def list_plans
    puts "testsdasfdsf"
    request('/pricing-plans;server-type=VPS')["pricing_plan_infos"]
  end

  def list_nodes
    request('/orders;include_inactive=N')["about_orders"]
  end

  def set_server_state(id, state)
    json = {"reboot_request" => {"running_state" => state}}.to_json
    request("/orders/order-#{id}-a/vps/running-state", json, 'PUT')
  end

  def delete_server(id)
    request("/orders/order-#{id}-a/vps",'', 'DELETE')
  end

  def create_server(image_id, flavor_id, name)
    json = {:new_vps => {:instantiation_options => {:domain_name => name, :distro => image_id},
                        :pricing_plan_code => flavor_id}}.to_json
    request('/orders/new-vps',json, 'POST')[:about_order]
  end
end

