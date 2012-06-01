ENV['API_DRIVER']   = "google"
ENV['TESTS_API_USERNAME']     = 'GOOGUM2I5ZVSPSV5H42U'
ENV['TESTS_API_PASSWORD'] = 'sXhLOsE4SYU+M7SKsTwwNX2YPpMOKIiRyZaZxcBp'

$:.unshift File.join(File.dirname(__FILE__), '..', '..', '..')
require 'tests/minitest_common'

require 'vcr'

VCR.configure do |c|
  c.cassette_library_dir = "#{File.dirname(__FILE__)}/fixtures/"
  c.hook_into :excon
  c.default_cassette_options = { :record => :new_episodes}
end

#the following can probably be moved to somewhere more 'common'
#once other driver tests start using them (e.g. openstack).

  @@created_bucket_name="testbucki2rpux3wdelme"
  @@created_blob_name="testblobk1ds91kVdelme"
  @@created_blob_local_file="#{File.dirname(__FILE__)}/../common_fixtures/deltacloud_blob_test.png"

  def check_bucket_basics(bucket, cloud)
    (bucket/'bucket/name').first.text.must_equal "#{@@created_bucket_name}#{cloud}"
    (bucket/'bucket').attribute("id").text.must_equal "#{@@created_bucket_name}#{cloud}"
    (bucket/'bucket').length.must_be :>, 0
    (bucket/'bucket/name').first.text.wont_be_nil
    (bucket/'bucket').attribute("href").text.wont_be_nil
  end

  def check_blob_basics(blob, cloud)
    (blob/'blob').length.must_equal 1
    (blob/'blob').attribute("id").text.wont_be_nil
    (blob/'blob').attribute("href").text.wont_be_nil
    (blob/'blob/bucket').text.wont_be_nil
    (blob/'blob/content_length').text.wont_be_nil
    (blob/'blob/content_type').text.wont_be_nil
    (blob/'blob').attribute("id").text.must_equal "#{@@created_blob_name}#{cloud}"
    (blob/'blob/bucket').text.must_equal "#{@@created_bucket_name}#{cloud}"
    (blob/'blob/content_length').text.to_i.must_equal File.size(@@created_blob_local_file)
  end

  def check_blob_metadata(blob, metadata_hash)
    meta_from_blob = {}
    #extract metadata from nokogiri blob xml
    (0.. (((blob/'blob/user_metadata').first).elements.size - 1) ).each do |i|
      meta_from_blob[(((blob/'blob/user_metadata').first).elements[i].attribute("key").value)] =
                                  (((blob/'blob/user_metadata').first).elements[i].children[1].text)
    end
    #remove any 'x-goog-meta-' prefixes (problem for google blobs and vcr...)
    meta_from_blob.gsub_keys(/x-.*-meta-/i, "")
    meta_from_blob.must_equal metadata_hash
  end

