$:.unshift File.join(File.dirname(__FILE__), '..', '..', '..')
require 'tests/drivers/rackspace/common'
#require 'webmock/test_unit'
module RackspaceTest

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

    @@created_bucket_name="testbucki2rpux3wdelme"
    @@created_blob_name="testblobk1ds91kVdelme"
    @@created_blob_local_file="#{File.dirname(__FILE__)}/fixtures/deltacloud_blob_test.png"

    def test_01_it_can_create_new_bucket
      params = {
        :name => @@created_bucket_name,
        :'api[driver]' => 'rackspace'
      }
      post_url '/api/buckets', params
      last_response.status.should == 201 # Created
      bucket = last_xml_response
      check_bucket_basics(bucket)
      (bucket/'bucket/size').first.text.should == "0"
    end

    def test_02_it_can_post_new_blob
      temp_file=File.open(@@created_blob_local_file)
      params = {
        'blob_id' => @@created_blob_name,
        :meta_params=>"2",
        :meta_name1=>"Author",
        :meta_value1=>"deltacloud",
        :meta_name2=>"foo",
        :meta_value2=>"bar",
        :'api[driver]' => 'rackspace'
      }
      uri="/api/buckets/#{@@created_bucket_name}"
      vcr_cassette = "post-"+Digest::SHA1.hexdigest("#{uri}-#{params.sort_by {|k,v| k.to_s}}")
      params.merge!({'blob_data' => Rack::Test::UploadedFile.new(temp_file.path, "text/html")})
      post_url uri, params, {'vcr_cassette'=>vcr_cassette}
      last_response.status.should == 200
      blob= last_xml_response
      check_blob_basics(blob)
    end

    def test_03_it_can_retrieve_named_bucket_details
       params = {
        :'api[driver]' => 'rackspace'
      }
      get_url "/api/buckets/#{@@created_bucket_name}", params
      last_response.status.should == 200
      bucket = last_xml_response
      check_bucket_basics(bucket)
      (bucket/'bucket/size').first.text.should == "1" #assuming blob created succesfully right?
    end

    def test_04_it_can_retrieve_named_blob_details
      params = {
                :'api[driver]' => 'rackspace'
               }
      get_url "/api/buckets/#{@@created_bucket_name}/#{@@created_blob_name}", params
      last_response.status.should == 200
      blob = last_xml_response
      check_blob_basics(blob)
      check_blob_metadata(blob, {"author"=>"deltacloud", "foo"=>"bar"})
    end

#    def test_05_it_can_retrieve_blob_metadata
#      params = {
#                :'api[driver]' => 'rackspace'
#               }
#      head_url "/api/buckets/#{@@created_bucket_name}/#{@@created_blob_name}", params
#      last_response.status.should == 204
#debugger
#      blob = last_xml_response
#      check_blob_basics(blob)
#      check_blob_metadata(blob, {"author"=>"deltacloud", "foo"=>"bar"})

#    end

    def test_06_it_can_update_blob_metadata
      params = {
                :'api[driver]' => 'rackspace'
               }
      new_meta = {"X-Deltacloud-Blobmeta-author" => "ApacheDeltacloud", "X-Deltacloud-Blobmeta-oof" => "rab"}
      new_meta.each_pair do |k,v|
        header k, v
      end
      post_url "/api/buckets/#{@@created_bucket_name}/#{@@created_blob_name}", params
      last_response.status.should == 204
      new_meta.each_pair do |k,v|
        (last_response.headers[k]==v).should == true
      end
    end

    def test_07_it_can_delete_blob
      params = {
                :'api[driver]' => 'rackspace'
               }
      delete_url "/api/buckets/#{@@created_bucket_name}/#{@@created_blob_name}", params
      last_response.status.should == 204
    end

    def test_08_it_can_delete_bucket
      params = {
                :'api[driver]' => 'rackspace'
               }
      delete_url "/api/buckets/#{@@created_bucket_name}", params
      last_response.status.should == 204
    end

    private

    def check_bucket_basics(bucket)
      (bucket/'bucket/name').first.text.should == @@created_bucket_name
      (bucket/'bucket').attribute("id").text.should == @@created_bucket_name
      (bucket/'bucket').length.should > 0
      (bucket/'bucket/name').first.text.should_not == nil
      (bucket/'bucket').attribute("href").text.should_not == nil
    end

    def check_blob_basics(blob)
      (blob/'blob').length.should == 1
      (blob/'blob').attribute("id").text.should_not == nil
      (blob/'blob').attribute("href").text.should_not==nil
      (blob/'blob/bucket').text.should_not == nil
      (blob/'blob/content_length').text.should_not == nil
      (blob/'blob/content_type').text.should_not == nil
      (blob/'blob').attribute("id").text.should == @@created_blob_name
      (blob/'blob/bucket').text.should == @@created_bucket_name
      (blob/'blob/content_length').text.to_i.should == File.size(@@created_blob_local_file)
    end

    def check_blob_metadata(blob, metadata_hash)
      (0.. (((blob/'blob/user_metadata').first).elements.size - 1) ).each do |i|
        metadata_hash.has_key?(((blob/'blob/user_metadata').first).elements[i].attribute("key").value).should == true
        metadata_hash.has_value?(((blob/'blob/user_metadata').first).elements[i].children[1].text).should == true
      end
    end

  end
end
