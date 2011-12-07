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

      def href_to_id(href) 
        href.split('/').last
      end

      def flash_block_for(message_type)
        return unless flash[message_type]
        capture_haml do
          haml_tag :div, :class => [ 'alert-message', message_type ] do
            haml_tag :a, :class => :close, :href => '#' do
              haml_concat 'x'
            end
            haml_tag :p do
              haml_concat flash[message_type]
            end
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
          haml_tag :span, :class => [ 'label', bool.nil? ? '' : (bool===false) ? 'important' : 'success' ] do
            haml_concat bool.nil? ? 'not specified' : (bool===false) ? 'no' : 'yes'
          end
        end
      end

      def state_span_for(state)
        capture_haml do
          haml_tag :span, :class => [ 'label', state=='STARTED' ? 'success' : 'important' ] do
            haml_concat state
          end
        end
      end

    end
  end
end
