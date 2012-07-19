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

class Hash
  def gsub_keys(rgx_pattern, replacement)
    remove = []
    new_hash = {}
    each_key do |key|
      if key.to_s.match(rgx_pattern)
         new_key = key.to_s.gsub(rgx_pattern, replacement).downcase
         new_hash[new_key] = self[key]
      else
        new_hash[key] = self[key]
      end
    end
    clear
    merge!(new_hash)
  end

  # Method copied from https://github.com/rails/rails/blob/77efc20a54708ba37ba679ffe90021bf8a8d3a8a/activesupport/lib/active_support/core_ext/hash/keys.rb#L23
  def symbolize_keys
    keys.each { |key| self[(key.to_sym rescue key) || key] = delete(key) }
    self
  end

end
