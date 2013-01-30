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
  module Helpers
    module FilterResourceMethods

      def filter_by(filter_opts)
        return self if filter_opts.nil?
        return self unless kind_of? CIMI::Model::Collection
        attribute, value = parse_filter_opts(filter_opts)
        if attribute =~ /\!$/
          attribute.chomp!('!')
          self.entries.delete_if { |entry| entry[attribute.to_sym] == value }
        else
          self.entries.delete_if { |entry| entry[attribute.to_sym] != value }
        end
        self
      end

      def parse_filter_opts(opts)
        attribute, value = opts.split('=')
        value.gsub!(/\A("|')|("|')\Z/, '')
        [attribute, value]
      end

    end
  end
end
