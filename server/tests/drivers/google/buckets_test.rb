require 'rubygems'
require 'require_relative' if RUBY_VERSION < '1.9'

require_relative 'common.rb'

require 'tempfile'

describe 'Deltacloud API' do

  before do
    @driver = Deltacloud::new(:google, credentials)
    VCR.insert_cassette __name__
  end

  after do
    VCR.eject_cassette
  end

  ## FIXME:
  i_suck_and_my_tests_are_order_dependent!

  def bucket_name_google
    "testbucki2rpux3wdelmegoogel"
  end

  def blob_name_google
    "testblobk1ds91kVdelmegoogel"
  end

  #intentional typos here - bucket names cannot contain 'google'
  #see http://code.google.com/apis/storage/docs/reference/v1/developer-guidev1.html
  it 'can create a new bucket' do
    bucket_name = bucket_name_google
    bucket = @driver.create_bucket(bucket_name)
    bucket.id.wont_be_nil
    bucket.name.must_equal bucket_name
    bucket.size.must_equal 0
    bucket.blob_list.must_be_empty
  end

  it 'can create a new blob with HTTP POST' do
    temp_file = File.open(created_blob_local_file)
    user_data = {
      'HTTP-X-Deltacloud-Blobmeta-name1' => "Author",
      'HTTP-X-Deltacloud-Blobmeta-value1' => "deltacloud",
      'HTTP-X-Deltacloud-Blobmeta-name2' => "foo",
      'HTTP-X-Deltacloud-Blobmeta-value2' => "bar"
    }
    blob = @driver.backend.create_blob(
      @driver.credentials,
      bucket_name_google,
      blob_name_google,
      { :tempfile => temp_file, :type => 'image/png'},
      user_data
    )
    blob.id.wont_be_nil
    blob.bucket.must_equal bucket_name_google
    blob.content_type.must_equal 'image/png'
    blob.user_metadata.keys.wont_be_empty
  end

  it 'can retrieve named bucket details' do
    bucket = @driver.bucket(:id => bucket_name_google)
    bucket.id.wont_be_nil
    bucket.name.must_equal bucket_name_google
    bucket.size.must_equal 1
    bucket.blob_list.wont_be_nil
    bucket.blob_list.must_include blob_name_google
  end

  it 'can retrieve details of a named blob' do
    blob = @driver.blob({:id => blob_name_google, 'bucket' => bucket_name_google})
    blob.bucket.must_equal bucket_name_google
    blob.id.must_equal blob_name_google
    blob.content_length.to_i.must_be :'>',0
    blob.last_modified.wont_be_empty
    blob.content_type.must_equal 'image/png'
    blob.user_metadata.keys.wont_be_empty
  end

  it 'can retrieve named blob metadata' do
    blob_metadata = @driver.blob_metadata({:id => blob_name_google, 'bucket' => bucket_name_google})
    {"name1"=>"Author", "value1"=>"deltacloud", "name2"=>"foo", "value2"=>"bar"}.must_equal blob_metadata
  end

  it 'can update blob metadata' do
    new_meta = { 'author' => 'ApacheDeltacloud', 'oof' => 'rab'}
    r = @driver.update_blob_metadata({:id => blob_name_google, 'bucket' => bucket_name_google, 'meta_hash' => new_meta})
    r.wont_be_nil
    r.keys.wont_be_empty
    r['author'].must_equal 'ApacheDeltacloud'
    r['oof'].must_equal 'rab'
  end

  it 'can delete blob' do
    r = @driver.delete_blob(bucket_name_google, blob_name_google)
    r.status.must_equal 204
  end

  it 'can delete bucket' do
    r = @driver.delete_bucket(bucket_name_google)
    r.status.must_equal 204
  end

end
