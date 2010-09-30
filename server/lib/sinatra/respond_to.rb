# respond_to (The MIT License)

# Permission is hereby granted, free of charge, to any person obtaining a copy of this software
# and associated documentation files (the 'Software'), to deal in the Software without restriction,
# including without limitation the rights to use, copy, modify, merge, publish, distribute,
# sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is 
# furnished to do so, subject to the following conditions:
#
# THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT 
# NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, 
# DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE

require 'sinatra/base'
require 'rack/accept'

use Rack::Accept

module Sinatra
  module RespondTo

    class MissingTemplate < Sinatra::NotFound; end

    # Define all MIME types you want to support here.
    # This conversion table will be used for auto-negotiation
    # with browser in sinatra when no 'format' parameter is specified.

    SUPPORTED_ACCEPT_HEADERS = {
      :xml => [
        'text/xml',
        'application/xml'
      ],
      :html => [
        'text/html',
        'application/xhtml+xml'
      ],
      :json => [
        'application/json'
      ]
    }

    # We need to pass array of available response types to
    # best_media_type method
    def accept_to_array
      SUPPORTED_ACCEPT_HEADERS.keys.collect do |key|
        SUPPORTED_ACCEPT_HEADERS[key]
      end.flatten
    end

    # Then, when we get best media type for response, we need
    # to know which format to choose
    def lookup_format_from_mime(mime)
      SUPPORTED_ACCEPT_HEADERS.keys.each do |format|
        return format if SUPPORTED_ACCEPT_HEADERS[format].include?(mime)
      end
    end

    def self.registered(app)

      app.helpers RespondTo::Helpers

      app.before do

        # Skip development error image and static content
        next if self.class.development? && request.path_info =~ %r{/__sinatra__/.*?.png}
        next if options.static? && options.public? && (request.get? || request.head?) && static_file?(request.path_info)

        # Remove extension from URI
        # Extension will be available as a 'extension' method (extension=='txt')
       
        request.path_info.sub! %r{\.([^\./]+)$}, ''
        extension $1

        # If ?format= is present, ignore all Accept negotiations because
        # we are not dealing with browser
        if request.params.has_key? 'format'
          format params['format'].to_sym
        end
        
        # Let's make a little exception here to handle
        # /api/instance_states[.gv/.png] calls
        if extension.eql?('gv')
          format :gv
        elsif extension.eql?('png')
          format :png
        end

        # Get Rack::Accept::Response object and find best possible
        # mime type to output.
        # This negotiation works fine with latest rest-client gem:
        #
        # RestClient.get 'http://localhost:3001/api', {:accept => :json } =>
        # 'application/json'
        # RestClient.get 'http://localhost:3001/api', {:accept => :xml } =>
        # 'application/xml'
        #
        # Also browsers like Firefox (3.6.x) and Chromium reporting
        # 'application/xml+xhtml' which is recognized as :html reponse
        # In browser you can force output using ?format=[format] parameter.

        rack_accept = env['rack-accept.request']

        if rack_accept.media_type.to_s.strip.eql?('Accept:')
          format :xml
        else
          format lookup_format_from_mime(rack_accept.best_media_type(accept_to_array))
        end

      end

      app.class_eval do
        # This code was copied from respond_to plugin
        # http://github.com/cehoffman/sinatra-respond_to
        # MIT License
        alias :render_without_format :render
        def render(*args, &block)
          assumed_layout = args[1] == :layout
          args[1] = "#{args[1]}.#{format}".to_sym if args[1].is_a?(::Symbol)
          render_without_format *args, &block
        rescue Errno::ENOENT => e
          raise MissingTemplate, "#{args[1]}.#{args[0]}" unless assumed_layout
          raise e
        end
        private :render
      end

      # This code was copied from respond_to plugin
      # http://github.com/cehoffman/sinatra-respond_to
      app.configure :development do |dev|
        dev.error MissingTemplate do
          content_type :html, :charset => 'utf-8'
          response.status = request.env['sinatra.error'].code

          engine = request.env['sinatra.error'].message.split('.').last
          engine = 'haml' unless ['haml', 'builder', 'erb'].include? engine

          path = File.basename(request.path_info)
          path = "root" if path.nil? || path.empty?

          format = engine == 'builder' ? 'xml' : 'html'

          layout = case engine
                   when 'haml' then "!!!\n%html\n  %body= yield"
                   when 'erb' then "<html>\n  <body>\n    <%= yield %>\n  </body>\n</html>"
                   end

          layout = "<small>app.#{format}.#{engine}</small>\n<pre>#{escape_html(layout)}</pre>"

          (<<-HTML).gsub(/^ {10}/, '')
          <!DOCTYPE html>
          <html>
          <head>
            <style type="text/css">
            body { text-align:center;font-family:helvetica,arial;font-size:22px;
              color:#888;margin:20px}
            #c {margin:0 auto;width:500px;text-align:left;}
            small {float:right;clear:both;}
            pre {clear:both;text-align:left;font-size:70%;width:500px;margin:0 auto;}
            </style>
          </head>
          <body>
            <h2>Sinatra can't find #{request.env['sinatra.error'].message}</h2>
            <img src='/__sinatra__/500.png'>
            <pre>#{request.env['sinatra.error'].backtrace.join("\n")}</pre>
            <div id="c">
              <small>application.rb</small>
              <pre>#{request.request_method.downcase} '#{request.path_info}' do\n  respond_to do |wants|\n    wants.#{format} { #{engine} :#{path} }\n  end\nend</pre>
            </div>
          </body>
          </html>
          HTML
        end

      end
    end

    module Helpers

      # This code was copied from respond_to plugin
      # http://github.com/cehoffman/sinatra-respond_to
      def self.included(klass)
        klass.class_eval do
          alias :content_type_without_save :content_type
          def content_type(*args)
            content_type_without_save *args
            @_format = args.first.to_sym
            response['Content-Type']
          end
        end
      end

      def static_file?(path)
        public_dir = File.expand_path(options.public)
        path = File.expand_path(File.join(public_dir, unescape(path)))

        path[0, public_dir.length] == public_dir && File.file?(path)
      end


      # Extension holds trimmed extension. This is extra usefull
      # when you want to build original URI (with extension)
      # You can simply call "#{request.env['REQUEST_URI']}.#{extension}"
      def extension(val=nil)
        @_extension ||= val
        @_extension
      end
      
      # This helper will holds current format. Helper should be
      # accesible from all places in Sinatra
      def format(val=nil)
        @_format ||= val
        @_format
      end

      def respond_to(&block)
        wants = {}
        
        def wants.method_missing(type, *args, &handler)
          self[type] = handler
        end
        
        # Set proper content-type and encoding for
        # text based formats
        if [:xml, :gv, :html, :json].include?(format)
          content_type format, :charset => 'utf-8'
        end
        yield wants
        # Raise this error if requested format is not defined
        # in respond_to { } block.
        raise MissingTemplate if wants[format].nil?

        wants[format].call
      end

    end

  end
end
