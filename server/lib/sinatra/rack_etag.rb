# Copyright (c) 2008 The Committers

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to
# deal in the Software without restriction, including without limitation the
# rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
# sell copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
# IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

module Rack
  # Automatically sets the ETag header on all String bodies.
  #
  # The ETag header is skipped if ETag or Last-Modified headers are sent or if
  # a sendfile body (body.responds_to :to_path) is given (since such cases
  # should be handled by apache/nginx).
  #
  # On initialization, you can pass two parameters: a Cache-Control directive
  # used when Etag is absent and a directive when it is present. The first
  # defaults to nil, while the second defaults to "max-age=0, privaute, must-revalidate"
  class ETag

    def initialize(app, no_cache_control = nil, cache_control = nil)
      @app = app
      @cache_control = cache_control || "max-age=0, private, must-revalidate"
      @no_cache_control = no_cache_control
    end

    def call(env)
      status, headers, body = @app.call(env)

      if etag_status?(status) && etag_body?(body) && !http_caching?(headers)
        digest, body = digest_body(body)
        headers['ETag'] = digest.to_s if digest
      end

      if not headers['Cache-Control'] and digest
        headers['Cache-Control'] = digest ? @cache_control : @no_cache_control
      end

      [status, headers, body]
    end

    private

      def etag_status?(status)
        status == 200 || status == 201
      end

      def etag_body?(body)
        !body.respond_to?(:to_path)
      end

      def http_caching?(headers)
        headers.key?('ETag') || headers.key?('Last-Modified')
      end

      def digest_body(body)
        parts = []
        if RUBY_VERSION =~ /^1\.8/
          body.each { |part, b| parts << part }
        else
          body.each { |part| parts << part }
        end
        string_body = parts.join
        digest = Digest::MD5.hexdigest(string_body) unless string_body.empty?
        [digest, parts]
      end
  end
end

