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

require_relative '../test_helper'

describe Fixnum do

  it 'support #is_redirect?' do
    300.must_respond_to :"is_redirect?"
    300.is_redirect?.must_equal true
    310.is_redirect?.must_equal true
    399.is_redirect?.must_equal true
    510.is_redirect?.must_equal false
  end

  it 'support #is_ok?' do
    200.must_respond_to :"is_ok?"
    200.is_ok?.must_equal true
    210.is_ok?.must_equal true
    299.is_ok?.must_equal true
    510.is_ok?.must_equal false
  end
end
