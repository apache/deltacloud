require "net/http"
require "net/https"
require "rubygems"
require "json"


class RimuHostingClient
  def initialize(name, password ,baseuri = 'http://localhost:8080/rimuhosting/r')
    @uri = URI.parse(baseuri)

    @service = Net::HTTP.new(@uri.host, @uri.port)
    @service.use_ssl = false
    @auth = "rimuhosting apikey=" % [password]
  end

  def request(resource, data='', method='GET')
    headers = {"Accept" => "application/json", "Content-Type" => "application/json", "Authorization" => @auth}
    r = @service.send_request(method, @uri.path + resource, data, headers)
    res = JSON.parse(r.body)  
    res[res.keys[0]]
  end

  def list_images
    request('/distributions')["distro_infos"]
  end

  def list_plans
    request('/pricing-plans;server-type=VPS')["pricing_plan_infos"]
  end

  def list_nodes
    request('/orders;include_inactive=N')["about_orders"]
  end

  def set_server_state(id, state)
    json = {:reboot_request => {:running_state => state}}
    request('/orders/order-#{id}/vps/running-state', json, 'PUT')
  end

  def delete_server(id)
    request('/orders/order-#{id}/vps','', 'DELETE')
  end
end

