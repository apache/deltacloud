#
# Based on https://github.com/emk/sinatra-url-for/
# Commit 1df339284203f8f6ed8d
#
# Original license:
# Copyright (C) 2009 Eric Kidd
#
# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to permit
# persons to whom the Software is furnished to do so, subject to the
# following conditions:
#
# The above copyright notice and this permission notice shall be included
# in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
# OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN
# NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
# DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
# OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE
# USE OR OTHER DEALINGS IN THE SOFTWARE.

module Sinatra
  module UrlForHelper

    require 'uri'

    def method_missing(name, *args)
      if name.to_s =~ /^([\w\_]+)_url$/
        if args.size > 0
          t = $1
          if t.match(/^(stop|reboot|start|attach|detach)_/)
            action = $1
            api_url_for(t.pluralize.split('_').last + '/' + args.first.to_s + '/' + action, :full)
          elsif t.match(/^(destroy|update)_/)
            api_url_for(t.pluralize.split('_').last + '/' + args.first.to_s, :full)
          else
            api_url_for(t.pluralize, :full) + '/' + "#{args.first}"
          end
        else
          api_url_for($1, :full)
        end
      else
        super
      end
    end

    def api_url_for(url_fragment, mode=:path_only)
      matrix_params = ''
      if request.params['api']
        matrix_params += ";provider=%s" % request.params['api']['provider'] if request.params['api']['provider']
        matrix_params += ";driver=%s" % request.params['api']['driver'] if request.params['api']['driver']
      end
      url_fragment = "/#{url_fragment}" unless url_fragment =~ /^\// # There is no need to prefix URI with '/'
      if mode == :path_only
        url_for "#{settings.root_url}#{matrix_params}#{url_fragment}", mode
      else
        url_for "#{matrix_params}#{url_fragment}", :full
      end
    end

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
        base = request.script_name.empty? ? Deltacloud[ENV['API_FRONTEND'] || :deltacloud].root_url : request.script_name
      when :full
        scheme = request.scheme
        port = request.port
        request_host = request.host
        if request.env['HTTP_X_FORWARDED_FOR']
          scheme = request.env['HTTP_X_FORWARDED_SCHEME'] || scheme
          port = request.env['HTTP_X_FORWARDED_PORT']
          request_host = request.env['HTTP_X_FORWARDED_HOST']
        end
        if (port.nil? || port == "" ||
            (scheme == 'http' && port.to_s == '80') ||
            (scheme == 'https' && port.to_s == '443'))
          port = ""
        else
          port = ":#{port}"
        end
        base = "#{scheme}://#{request_host}#{port}#{request.script_name.empty? ? settings.config.root_url : request.script_name}"
      else
        raise TypeError, "Unknown url_for mode #{mode}"
      end
      uri_parser = URI.const_defined?(:Parser) ? URI::Parser.new : URI
      url_escape = uri_parser.escape(url_fragment)
      # Don't add the base fragment if url_for gets called more than once
      # per url or the url_fragment passed in is an absolute url
      if url_escape.match(/^#{base}/) or url_escape.match(/^http/)
        url_escape
      else
        "#{base}#{url_escape}"
      end
    end
  end

end
