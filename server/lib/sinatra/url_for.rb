require 'uri'

module Sinatra
  module UrlForHelper
    # Construct a link to +url_fragment+, which should be given relative to
    # the base of this Sinatra app.  The mode should be either
    # <code>:path_only</code>, which will generate an absolute path within
    # the current domain (the default), or <code>:full</code>, which will
    # include the site name and port number.  (The latter is typically
    # necessary for links in RSS feeds.)  Example usage:
    #
    #   url_for "/"            # Returns "/myapp/"
    #   url_for "/foo"         # Returns "/myapp/foo"
    #   url_for "/foo", :full  # Returns "http://example.com/myapp/foo"
    #--
    # See README.rdoc for a list of some of the people who helped me clean
    # up earlier versions of this code.
    def url_for url_fragment, mode=:path_only
      case mode
      when :path_only
        base = request.script_name
      when :full
        scheme = request.env['HTTP_X_FORWARDED_SCHEME'] || request.scheme
        port = request.env['HTTP_X_FORWARDED_PORT'] || request.port
        if ((scheme == 'http' && port.to_s == '80') ||
            (scheme == 'https' && port.to_s == '443'))
          port = ""
        else
          port = ":#{port}"
        end
        request_host = HOSTNAME ? HOSTNAME : request.host
        base = "#{scheme}://#{request_host}#{port}#{request.script_name}"
      else
        raise TypeError, "Unknown url_for mode #{mode}"
      end
      url_escape = URI.escape(url_fragment)
      # Don't add the base fragment if url_for gets called more than once
      # per url or the url_fragment passed in is an absolute url
      if url_escape.match(/^#{base}/) or url_escape.match(/^http/)
        url_escape
      else
        "#{base}#{url_escape}"
      end
    end

    def root_url
      url_for '/'
    end
  end



  helpers UrlForHelper
end
