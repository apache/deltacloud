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
    module SelectResourceMethods

      def select_by(filter_opts)
        return self if filter_opts.nil?
        return self unless kind_of? CIMI::Model::Collection
        if filter_opts.include? ','
          return select_attributes(filter_opts.split(',').map{ |a| a.intern })
        end
        case filter_opts
        when /^([\w\_]+)$/ then select_attributes([$1.intern])
        when /^([\w\_]+)\[(\d+\-\d+)\]$/ then select_by_arr_range($1.intern, $2)
        when /^([\w\_]+)\[(\d+)\]$/ then select_by_arr_index($1.intern, $2)
        else self
        end
      end

      def select_by_arr_index(attr, filter)
        return self unless self.respond_to?(attr)
        self.class.new(attr => [self.send(attr)[filter.to_i]])
      end

      def select_by_arr_range(attr, filter)
        return self unless self.respond_to?(attr)
        filter = filter.split('-').inject { |s,e| s.to_i..e.to_i }
        self.class.new(attr => self.send(attr)[filter])
      end

    end

    module SelectBaseMethods
      def select_attributes(attr_list)
        attrs = attr_list.inject({}) do |result, attr|
          attr = attr.to_s.underscore
          result[attr.to_sym] = self.send(attr) if self.respond_to?(attr)
          result
        end
        self.class.new(attrs.merge(
          :select_attr_list => attr_list,
          :base_id => self.send(:id)
        ))
      end
    end

  end
end
