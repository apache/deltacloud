module DeltaCloud
  module TestHelper

    include Test::Unit::Assertions

    API_URL   = "http://localhost:3001/api"
    API_USER  = "mockuser"
    API_PASWD = "mockpassword"

    def base_client(args)
      `bin/deltacloudc #{args}`
    end

    def client(args)
      args = "-u http://mockuser:mockpassword@localhost:3001/api " + args
      base_client(args)
    end

    def assert_no_warning(output)
      assert_no_match /\[WARNING\] Method unsupported by API: '(\w+)'/, output
    end

  end
end
