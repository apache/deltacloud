require "net/http"
require "net/https"
require 'rubygems'
require 'json'


class RackspaceClient

  @@AUTH_API = URI.parse('https://auth.api.rackspacecloud.com/v1.0')
  
  def initialize(username, auth_key)
    http = Net::HTTP.new(@@AUTH_API.host,@@AUTH_API.port)
    http.use_ssl = true
    authed = http.get(@@AUTH_API.path, {'X-Auth-User' => username, 'X-Auth-Key' => auth_key})
    @auth_token  = authed.header['X-Auth-Token']
    @service_uri = URI.parse(authed.header['X-Server-Management-Url'])
    @service = Net::HTTP.new(@service_uri.host, @service_uri.port)
    @service.use_ssl = true
  end

  def get(path) 
    @service.get(@service_uri.path + path, {"Accept" => "application/json", "X-Auth-Token" => @auth_token}).body
  end

  def list_flavors
    JSON.parse(get('/flavors/detail'))['flavors']
  end

  def list_images 
    JSON.parse(get('/images/detail'))['images']
  end

  def list_instances
    JSON.parse(get('/servers/detail'))['servers']
  end

  def start_server(image_id, flavor_id, name)
    json = { :server => { :name => name, :imageId => image_id, :flavorId => flavor_id }}.to_json
    resp = @service.post(@service_uri.path + "/servers", json, {"Accept" => "application/json", "X-Auth-Token" => @auth_token, "Content-Type" => "application/json"}).body
    JSON.parse(resp)
  end






end




