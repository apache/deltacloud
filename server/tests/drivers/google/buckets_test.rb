module GoogleTest

  class BucketsTest < Test::Unit::TestCase
    include Rack::Test::Methods

    def app
      Rack::Builder.new {
        map '/' do
          use Rack::Static, :urls => ["/stylesheets", "/javascripts"], :root => "public"
          run Rack::Cascade.new([Deltacloud::API])
        end
      }
    end

    @@bucket_name_google="#{@@created_bucket_name}googel"
    @@blob_name_google="#{@@created_blob_name}googel"
#intentional typos here - bucket names cannot contain 'google'
#see http://code.google.com/apis/storage/docs/reference/v1/developer-guidev1.html

   def test_01_it_can_create_new_bucket
      params = {
        :name => @@bucket_name_google,
        :'api[driver]' => 'google'
      }
      vcr_cassette = stable_vcr_cassette_name('post', '/api/buckets', params)
      post_url '/api/buckets', params, {'vcr_cassette'=>vcr_cassette}
      last_response.status.should == 201 # Created
      bucket = last_xml_response
      check_bucket_basics(bucket, "googel")
      (bucket/'bucket/size').first.text.should == "0"
    end

    def test_02_it_can_post_new_blob
      temp_file=File.open(@@created_blob_local_file)
      params = {
        'blob_id' => @@blob_name_google,
        :meta_params=>"2",
        :meta_name1=>"Author",
        :meta_value1=>"deltacloud",
        :meta_name2=>"foo",
        :meta_value2=>"bar",
        :'api[driver]' => 'google'
      }
      uri="/api/buckets/#{@@bucket_name_google}"
      vcr_cassette = stable_vcr_cassette_name('post', uri, params)
      params.merge!({'blob_data' => Rack::Test::UploadedFile.new(temp_file.path, "text/html")})
      post_url uri, params, {'vcr_cassette'=>vcr_cassette}
      last_response.status.should == 200
      blob= last_xml_response
      check_blob_basics(blob, "googel")
    end

    def test_03_it_can_retrieve_named_bucket_details
       params = {
        :'api[driver]' => 'google'
      }
      get_url "/api/buckets/#{@@bucket_name_google}", params
      last_response.status.should == 200
      bucket = last_xml_response
      check_bucket_basics(bucket, "googel")
      (bucket/'bucket/size').first.text.should == "1" #assuming blob created succesfully right?
    end

    def test_04_it_can_retrieve_named_blob_details
      params = {
                :'api[driver]' => 'google'
               }
      get_url "/api/buckets/#{@@bucket_name_google}/#{@@blob_name_google}", params
      last_response.status.should == 200
      blob = last_xml_response
      check_blob_basics(blob, "googel")
      check_blob_metadata(blob, {"author"=>"deltacloud", "foo"=>"bar"})
    end

    def test_05_it_can_retrieve_blob_metadata
      params = {
                :'api[driver]' => 'google'
               }
      head_url "/api/buckets/#{@@bucket_name_google}/#{@@blob_name_google}", params
      last_response.status.should == 200
      puts last_response.body
      blob_meta_hash = last_response.headers.inject({}){|result, (k,v)| result[k]=v if k=~/^X-Deltacloud-Blobmeta-/i ; result}
      blob_meta_hash.gsub_keys(/x-.*meta-/i, "")
      ({"author"=>"deltacloud", "foo"=>"bar"}.eql?(blob_meta_hash)).should == true
    end

    def test_06_it_can_update_blob_metadata
      params = {
                :'api[driver]' => 'google'
               }
      new_meta = {"X-Deltacloud-Blobmeta-author" => "ApacheDeltacloud", "X-Deltacloud-Blobmeta-oof" => "rab"}
      new_meta.each_pair do |k,v|
        header k, v
      end
      post_url "/api/buckets/#{@@bucket_name_google}/#{@@blob_name_google}", params
      last_response.status.should == 204
      new_meta.each_pair do |k,v|
        (last_response.headers[k]==v).should == true
      end
    end

    def test_07_it_can_delete_blob
      params = {
                :'api[driver]' => 'google'
               }
      delete_url "/api/buckets/#{@@bucket_name_google}/#{@@blob_name_google}", params
      last_response.status.should == 204
    end

    def test_08_it_can_delete_bucket
      params = {
                :'api[driver]' => 'google'
               }
      delete_url "/api/buckets/#{@@bucket_name_google}", params
      last_response.status.should == 204
    end

  end
end
