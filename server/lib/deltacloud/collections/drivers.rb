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

module Deltacloud::Collections
  class Drivers < Base

    collection :drivers do

      operation :index do
        control do
          @drivers = Deltacloud::Drivers.driver_config
          respond_to do |format|
            format.xml { haml :"drivers/index" }
            format.json { @drivers.to_json }
            format.html { haml :"drivers/index" }
          end
        end
      end

      operation :show do
        control do
          @name = params[:id].to_sym
          if driver_symbol == @name
            @providers = driver.providers(credentials)  if driver.respond_to? :providers
          end
          @driver = Deltacloud::Drivers.driver_config[@name]
          halt 404 unless @driver
          respond_to do |format|
            format.xml { haml :"drivers/show" }
            format.json { { :driver => @driver.merge(:id => params[:id]) }.to_json }
            format.html { haml :"drivers/show" }
          end
        end
      end

    end

  end
end
