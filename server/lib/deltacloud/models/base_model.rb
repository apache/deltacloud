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


class BaseModel

  attr_accessor :name, :description

  def initialize(init=nil)
    if ( init )
      @id=init[:id]
      init.each{|k,v|
        self.send( "#{k}=", v ) if ( self.respond_to?( "#{k}=" ) )
      }
    end
  end

  def self.attr_accessor(*vars)
    @attributes ||= [:id]
    @attributes.concat vars
    super
  end

  def self.attributes
    @attributes
  end

  def attributes
    self.class.attributes
  end

  def id
    @id
  end

  def to_entity
    self.class.name.downcase
  end

end
