# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.  The
# ASF licenses this file to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance with the
# License.  You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  See the
# License for the specific language governing permissions and limitations
# under the License.

module CIMI
  module Frontend
    module Helper

      require 'uri'

      def href_to_id(href) 
        href.split('/').last
      end

      def flash_block_for(message_type)
        return unless flash[message_type]
        capture_haml do
          haml_tag :div, :class => [ 'alert', 'fade', 'in', message_type ] do
            haml_tag :a, :class => :close, :href => '#' do
              haml_concat 'x'
            end
            haml_concat flash[message_type]
          end
        end
      end

      def flash
        @_flash ||= {}
      end

      def redirect(uri, *args)
        session[:_flash] = flash unless flash.empty?
        status 302
        response['Location'] = uri
        halt(*args)
      end

      def boolean_span_for(bool)
        return bool if !bool.nil? and bool!='true' and bool!='false'
        capture_haml do
          haml_tag :span, :class => [ 'label', bool.nil? ? '' : (bool===false) ? 'label-important' : 'label-success' ] do
            haml_concat bool.nil? ? 'Not specified' : (bool===false) ? 'no' : 'yes'
          end
        end
      end

      def state_span_for(state)
        capture_haml do
          haml_tag :span, :class => [ 'label', state=='STARTED' ? 'label-success' : 'label-important' ] do
            haml_concat state
          end
        end
      end

      def relativize_url(absolute_url)
        URI.parse(absolute_url).path
      end

      def convert_urls(value)
        value.gsub( %r{http(s?)://[^\s<]+} ) { |url| "<a href='#{relativize_url(url)}'>#{href_to_id(url)}</a>" }
      end

      def not_implemented(collection_name)
        return unless ['machine_templates', 'volume_templates'].include?(collection_name)
        capture_haml do
          haml_tag :span, :class => [ :label, :warning ] do
            haml_concat 'pending'
          end
        end
      end

      def struct_to_name(struct_name)
        struct_name.class.name.split('_').last
      end

      def row(label, value)
        haml_tag :tr do
          haml_tag :th do
            haml_concat label
          end
          haml_tag :td do
            haml_concat value.nil? ? '' : convert_urls(value)
          end
        end
      end

      def details(title='', &block)
        haml_tag :table, { :class => 'table table-bordered table-striped' } do
          haml_tag :caption do
            haml_tag :h3 do
              haml_concat title
            end
          end unless title.empty?
          haml_tag :tbody, &block
        end
      end

    end
  end
end
