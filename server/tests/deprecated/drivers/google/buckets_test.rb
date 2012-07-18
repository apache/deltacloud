$:.unshift File.join(File.dirname(__FILE__), '..', '..', '..')
require 'tests/drivers/google/common'

describe 'Deltacloud API' do

  before do
    VCR.insert_cassette __name__
  end

  after do
    VCR.eject_cassette
  end

  include Deltacloud::Test

i_suck_and_my_tests_are_order_dependent!

    @@bucket_name_google="#{@@created_bucket_name}googel"
    @@blob_name_google="#{@@created_blob_name}googel"
#intentional typos here - bucket names cannot contain 'google'
#see http://code.google.com/apis/storage/docs/reference/v1/developer-guidev1.html
  it 'can create a new bucket' do
    authenticate
    bucket_name = @@bucket_name_google
    post collection_url(:buckets), {:name=>bucket_name}
    last_response.status.must_equal 201
    bucket = xml_response
    check_bucket_basics(bucket, "googel")
    (bucket/'bucket/size').first.text.must_equal "0"
  end

  it 'can create a new blob with HTTP POST' do
    authenticate
    temp_file=File.open(@@created_blob_local_file)
    params = { 'blob_id' => @@blob_name_google,
              :meta_params=>"2",
              :meta_name1=>"Author",
              :meta_value1=>"deltacloud",
              :meta_name2=>"foo",
              :meta_value2=>"bar",
              'blob_data' => Rack::Test::UploadedFile.new(temp_file.path, "text/html") }
    post "#{collection_url(:buckets)}/#{@@bucket_name_google}", params
    last_response.status.must_equal 200
    blob = xml_response
    check_blob_basics(blob, "googel")
  end

  it 'can retrieve named bucket details' do
    authenticate
    get "#{collection_url(:buckets)}/#{@@bucket_name_google}"
    last_response.status.must_equal 200
    bucket = xml_response
    check_bucket_basics(bucket, "googel")
    (bucket/'bucket/size').first.text.must_equal "1" #assuming blob created succesfully right?
  end

  it 'can retrieve details of a named blob' do
      authenticate
      get "#{collection_url(:buckets)}/#{@@bucket_name_google}/#{@@blob_name_google}"
      last_response.status.must_equal 200
      blob = xml_response
      check_blob_basics(blob, "googel")
      check_blob_metadata(blob, {"author"=>"deltacloud", "foo"=>"bar"})
  end

  it 'can retrieve named blob metadata' do
    authenticate
    head "#{collection_url(:buckets)}/#{@@bucket_name_google}/#{@@blob_name_google}"
    last_response.status.must_equal 204
    blob_meta_hash = last_response.headers.inject({}){|result, (k,v)| result[k]=v if k=~/^X-Deltacloud-Blobmeta-/i ; result}
    blob_meta_hash.gsub_keys(/x-.*meta-/i, "")
    {"author"=>"deltacloud", "foo"=>"bar"}.must_equal blob_meta_hash
  end

  it 'can update blob metadata' do
    authenticate
    new_meta = {"X-Deltacloud-Blobmeta-author" => "ApacheDeltacloud", "X-Deltacloud-Blobmeta-oof" => "rab"}
    new_meta.each_pair do |k,v|
      header k, v
    end
    post "#{collection_url(:buckets)}/#{@@bucket_name_google}/#{@@blob_name_google}"
    last_response.status.must_equal 204
    new_meta.each_pair do |k,v|
      last_response.headers[k].must_equal v
    end
  end

  it 'can delete blob' do
    authenticate
    delete "#{collection_url(:buckets)}/#{@@bucket_name_google}/#{@@blob_name_google}"
    last_response.status.must_equal 204
  end

  it 'can delete bucket' do
    authenticate
    delete "#{collection_url(:buckets)}/#{@@bucket_name_google}"
    last_response.status.must_equal 204
  end

end
