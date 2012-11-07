#
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

$:.unshift File.join(File.dirname(__FILE__))

require "test_helper.rb"

class NetworkCollectionBehavior < CIMI::Test::Spec

  need_collection :networks

  model :networks, CIMI::Model::NetworkCollection do |fmt|
    coll_uri = cep(:accept => :json).json["networks"]["href"]
    get(coll_uri, :accept => fmt)
  end

  it "must have the \"id\" and \"count\" attributes" do
    networks.count.wont_be_nil
    networks.count.to_i.must_equal networks.entries.size
    networks.id.must_be_uri
  end

  it "must have a valid id and name for each member" do
    networks.entries.each do |entry|
      entry.id.must_be_uri
      member = fetch(entry.id, CIMI::Model::Network)
      member.id.must_equal entry.id
      member.name.must_equal entry.name
    end
  end
end
