module DocumentationHelper
  def documentation_pages
    [
      { :href => 'documentation.html', :menu => 'Installation', :description => 'Installation, dependencies and quick-start (this page)' },
      { :href => "api.html" , :menu => 'REST API', :description => 'REST API definition' },
      { :href => "drivers.html" , :menu => 'Drivers', :description => 'Information about currently supported drivers' },
      { :href => "client-ruby.html" , :menu => 'Ruby Client', :description => 'The Deltacloud Ruby client' },
      { :href => "libdeltacloud.html", :menu => "Libdeltacloud", :description => "The libdeltacloud C library" },
    ]
  end

end

Webby::Helpers.register(DocumentationHelper)
