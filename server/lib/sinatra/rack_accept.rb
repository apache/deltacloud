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

module Rack

  module RespondTo

    # This method is triggered after this helper is registred
    # within Sinatra.
    # We need to overide the default render method to supply correct path to the
    # template, since Sinatra is by default looking in the current __FILE__ path
    def self.registered(app)
      app.helpers Rack::RespondTo::Helpers
      app.class_eval do
        alias :render_without_format :render
        def render(*args, &block)
          begin
            assumed_layout = args[1] == :layout
            args[1] = "#{args[1]}.#{@media_type}".to_sym if args[1].is_a?(::Symbol)
            render_without_format *args, &block
          rescue Errno::ENOENT => e
            raise "ERROR: Missing template: #{args[1]}.#{args[0]}" unless assumed_layout
            raise e
          end
        end
        private :render
      end
    end

      module Helpers

        # This code was inherited from respond_to plugin
        # http://github.com/cehoffman/sinatra-respond_to
        #
        # This method is used to overide the default content_type returned from
        # rack-accept middleware.
        def self.included(klass)
          klass.class_eval do
            alias :content_type_without_save :content_type
            def content_type(*args)
              content_type_without_save *args
              request.env['rack-accept.formats'] = { args.first.to_sym => 1 }
              response['Content-Type']
            end
          end
        end

        def accepting_formats
          request.env['rack-accept.formats']
        end

        def static_file?(path)
          public_dir = File.expand_path(settings.public)
          path = File.expand_path(File.join(public_dir, unescape(path)))
          path[0, public_dir.length] == public_dir && File.file?(path)
        end

        def respond_to(&block)
          wants = {}
          def wants.method_missing(type, *args, &handler)
            self[type] = handler
          end
          yield wants
          @media_type = accepting_formats.to_a.sort { |a,b| a[1]<=>b[1] }.reverse.select do |format, priority|
            wants.keys.include?(format) == true
          end.first
          if @media_type and @media_type[0]
            @media_type = @media_type[0]
            headers 'Content-Type' => Rack::MediaType::ACCEPTED_MEDIA_TYPES[@media_type][:return]
            wants[@media_type.to_sym].call if wants[@media_type.to_sym]
          else
            headers 'Content-Type' => nil
            status 406
          end
        end

    end

  end

  class MediaType < Sinatra::Base

    include Rack::RespondTo::Helpers

    # Define supported media types here
    # The :return key stands for content-type which will be returned
    # The :match key stands for the matching Accept header
    ACCEPTED_MEDIA_TYPES = {
      :xml => { :return => 'application/xml', :match => ['application/xml', 'text/xml'] },
      :json => { :return => 'application/json', :match => ['application/json'] },
      :html => { :return => 'text/html', :match => ['application/xhtml+xml', 'text/html', '*/*'] },
      :png => { :return => 'image/png', :match => ['image/png'] },
      :gv => { :return => 'application/ghostscript', :match => ['application/ghostscript'] }
    }

    def call(env)
      accept, index = env['rack-accept.request'], {}

      # Skip everything when 'format' parameter is set in URL
      if env['rack.request.query_hash']["format"]
         media_type = case env['rack.request.query_hash']["format"]
            when 'html' then :html
            when 'xml' then :xml
            when 'json' then :json
            when 'gv' then :gv
            when 'png' then :png
          end
        index[media_type] = 1 if media_type
      else
        # Sort all requested media types in Accept using their 'q' values
        sorted_media_types = accept.media_type.qvalues.to_a.sort{ |a,b| a[1]<=>b[1] }.collect { |t| t.first }
        # If Accept header is missing or is empty, fallback to XML format
        sorted_media_types << 'application/xml' if sorted_media_types.empty?
        # Choose the right format with the media type according to the priority
        ACCEPTED_MEDIA_TYPES.each do |format, definition|
          definition[:match].each do |media_type|
            break if index[format] = sorted_media_types.index(media_type)
          end
        end
        # Reject formats with no/nil priority
        index.reject! { |format, priority| not priority }
      end

      #puts sorted_media_types.inspect
      #puts index.inspect

      # If after all we don't have any matching format assume that client has
      # requested unknown/wrong media type and throw an 406 error with no body
      if index.keys.empty?
        status, headers, response = 406, {}, ""
      else
        env['rack-accept.formats'] = index
        status, headers, response = @app.call(env)
      end
      [status, headers, response]
    end

  end

end

