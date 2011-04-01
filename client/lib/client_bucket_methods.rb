module ClientBucketMethods

  def create_bucket(params)
    obj = nil
    request(:post, "#{api_uri.to_s}/buckets", {:name => params['id'] }) do |response|
      handle_backend_error(response) if response.code!=201
      obj = base_object(:bucket, response)
    end
  end

  def destroy_bucket(params)
    #actually response here is 204 - no content - so nothing returned to client?
    request(:delete, "#{api_uri.to_s}/buckets/#{params['id']}") do |response|
      handle_backend_error(response) if response.code!=204
      response
    end
  end

  def create_blob(params)
    blob = nil
    resource = RestClient::Resource.new("#{api_uri.to_s}/buckets/#{params['bucket']}", :open_timeout => 10, :timeout => 45)
    headers = default_headers.merge(extended_headers)
    unless params['metadata'].nil?
      metadata_headers = {}
      params['metadata'].each   do |k,v|
        metadata_headers["X-Deltacloud-Blobmeta-#{k}"] = v
      end
      headers = headers.merge(metadata_headers)
    end
    resource.send(:post, {:blob_data => File.new(params['file_path'], 'rb'), :blob_id => params[:id]}, headers) do |response, request, block|
      handle_backend_error(response) if response.code.eql?(500)
      blob = base_object(:blob, response)
      yield blob if block_given?
    end
    return blob
  end

  def destroy_blob(params)
    request(:delete, "#{api_uri.to_s}/buckets/#{params['bucket']}/#{params[:id]}") do |response|
      handle_backend_error(response) if response.code!=204
      response
    end
  end

  #RestClient doesn't do streaming 'get' yet - we already opened a pull request on this see
  #https://github.com/archiloque/rest-client/issues/closed#issue/62 - apparently its going to
  #be in the next version - unknown when. For now get full response. FIXME
  def blob_data(params)
    request(:get, "#{api_uri.to_s}/buckets/#{params['bucket']}/#{params[:id]}/content") do |response|
      response
    end
  end

end