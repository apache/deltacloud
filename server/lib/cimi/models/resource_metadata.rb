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


class CIMI::Model::ResourceMetadata < CIMI::Model::Base

  # FIXME: Is this property really needed? (Base model include 'name'
  text :name

  text :type_uri

  array :attributes do
    scalar :name
    scalar :namespace
    scalar :type
    scalar :required
    array :constraints do
      text :value
    end
  end

  array :capabilities do
    scalar :name
    scalar :uri
    scalar :description
    scalar :value, :text => :direct
  end


  array :actions do
    scalar :name
    scalar :uri
    scalar :description
    scalar :method
    scalar :input_message
    scalar :output_message
  end

  array :operations do
    scalar :rel, :href
  end
end
