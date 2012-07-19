
%x[rake mock:fixtures:reset]

if ENV['COVERAGE']
  begin
    require 'simplecov'
    SimpleCov.start do
      command_name 'Minitest tests'
      project_name 'Deltacloud API'
      add_filter "tests/"
      add_group 'Drivers', 'lib/deltacloud/drivers'
      add_group 'Collections', 'lib/deltacloud/collections'
      add_group 'Models', 'lib/deltacloud/models'
      add_group 'Helpers', 'lib/deltacloud/helpers'
      add_group 'Extensions', 'lib/deltacloud/core_ext'
      add_group 'Sinatra', 'lib/sinatra'
    end
  rescue LoadError
    warn "To generate code coverage you need to install 'simplecov' (gem install simplecov OR bundle)"
  end
end
