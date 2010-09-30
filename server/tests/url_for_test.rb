require 'tests/common'

module DeltacloudUnitTest
  class UrlForTest < Test::Unit::TestCase
    include Rack::Test::Methods

    def app
      Sinatra::Application
    end

    def test_it_works_for_root
      verify_url_for("/", "/")
    end

    def test_it_works_for_root_absolute
      verify_url_for("/", "http://localhost/", :full)
    end

    def test_it_works_with_spaces
      verify_url_for("/url with spaces", "/url%20with%20spaces")
    end

    def test_it_works_when_given_absolute
      verify_url_for("http://test.com", "http://test.com")
    end

    def test_it_works_when_not_at_root_context
      verify_url_for("/", "context/", :path_only, {}, {"SCRIPT_NAME" => "context"})
    end

    def verify_url_for(url, expected_url, mode=:path_only, params={}, rack_env={})
      # generate a unique url for each test
      test_url = "/url_for_test/#{expected_url.hash}/#{Time.now.to_i}"
      # Create our sinatra test endpoint
      self.class.create_test_url_content(test_url, url, mode)

      # verify the generated url matches what we expect
      get test_url, params, rack_env
      last_response.body.should == expected_url
    end

    def self.create_test_url_content(test_url, url_content, mode)
      get test_url do
        content_type "text/plain"
          url_for(url_content, mode)
      end
    end

  end
end
