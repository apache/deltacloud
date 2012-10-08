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
  class LoadBalancers < Base

    set :capability, lambda { |m| driver.respond_to? m }

    new_route_for :load_balancers do
      @realms = driver.realms(credentials)
    end

    collection :load_balancers do
      description "Load balancers are used to distribute workload across multiple instances"

      standard_index_operation

      operation :show, :with_capability => :load_balancer do
        param :id, :string, :required
        control do
          @load_balancer = driver.load_balancer(credentials, params)
          @registered_instances = @load_balancer.instances.collect{|i| {:id => i.id, :name=> i.name}}
          # if provider supports realm_filter and load balancer has only one realm (which is mostly the case), use optimization:
          if @load_balancer.realms.size == 1 and driver.class.has_feature?(:instances, :realm_filter)
            all_instances = driver.instances(credentials, :realm_id => @load_balancer.realms.first.id).collect{|i| {:id => i.id, :name => i.name}}
          elsif
            all_instances = driver.instances(credentials).collect{|i| {:id => i.id, :name => i.name} }
          end
          @unregistered_instances = all_instances - @registered_instances
          respond_to do |format|
            format.xml { haml :'load_balancers/show' }
            format.json { xml_to_json('load_balancers/show') }
            format.html { haml :'load_balancers/show' }
          end
        end
      end

      operation :create, :with_capability => :create_load_balancer do
        param :name,  :string,  :required
        param :realm_id,  :string,  :required
        param :listener_protocol,  :string,  :required, ['HTTP', 'TCP']
        param :listener_balancer_port,  :string,  :required
        param :listener_instance_port,  :string,  :required
        control do
          @load_balancer = driver.create_load_balancer(credentials, params)
          status 201  # Created
          response['Location'] = load_balancer_url(@load_balancer.id)
          respond_to do |format|
            format.xml  { haml :"load_balancers/show" }
            format.json { xml_to_json("load_balancers/show")}
            format.html { redirect load_balancer_url(@load_balancer.id)}
          end
        end
      end

      action :register, :with_capability => :lb_register_instance do
        param :id, :string, :required
        param :instance_id, :string,  :required
        control do
          driver.lb_register_instance(credentials, params)
          @load_balancer = driver.load_balancer(credentials, :id => params[:id])
          respond_to do |format|
            format.xml { haml :'load_balancers/show' }
            format.json { xml_to_json('load_balancers/show') }
            format.html { redirect load_balancer_url(@load_balancer.id)}
          end
        end
      end

      action :unregister, :with_capability => :lb_unregister_instance do
        param :id, :string, :required
        param :instance_id, :string,  :required
        control do
          driver.lb_unregister_instance(credentials, params)
          @load_balancer = driver.load_balancer(credentials, :id => params[:id])
          respond_to do |format|
            format.xml { haml :'load_balancers/show' }
            format.json { xml_to_json('load_balancers/show')}
            format.html { redirect load_balancer_url(@load_balancer.id) }
          end
        end
      end

      operation :destroy, :with_capability => :destroy_load_balancer do
        control do
          driver.destroy_load_balancer(credentials, params[:id])
          status 204
          respond_to do |format|
            format.xml
            format.json
            format.html { redirect(load_balancers_url) }
          end
        end
      end

    end

  end
end
