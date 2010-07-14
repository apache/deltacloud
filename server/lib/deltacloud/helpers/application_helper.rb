#
# Copyright (C) 2009  Red Hat, Inc.
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

# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def bread_crumb
    s = "<ul class='breadcrumb'><li class='first'><a href='/'>&#948</a></li>"
    url = request.path.split('?')  #remove extra query string parameters
    levels = url[0].split('/') #break up url into different levels
    levels.each_with_index do |level, index|
      unless level.blank?
        if index == levels.size-1 ||
           (level == levels[levels.size-2] && levels[levels.size-1].to_i > 0)
          s += "<li class='subsequent'>#{level.gsub(/_/, ' ')}</li>\n" unless level.to_i > 0
        else
            link = levels.slice(0, index+1).join("/")
            s += "<li class='subsequent'><a href=\"#{link}\">#{level.gsub(/_/, ' ')}</a></li>\n"
        end
      end
    end
    s+="</ul>"
  end

  def instance_action_method(action)
    collections[:instances].operations[action.to_sym].method
  end

  def driver_has_feature?(feature_name)
    not driver.features(:instances).select{ |f| f.name.eql?(feature_name) }.empty?
  end

  def driver_has_auth_features?
    driver_has_feature?(:authentication_password) || driver_has_feature?(:authentication_key)
  end

  def driver_auth_feature_name
    return 'key' if driver_has_feature?(:authentication_key)
    return 'password' if driver_has_feature?(:authentication_password)
  end

  def filter_all(model)
      filter = {}
      filter.merge!(:id => params[:id]) if params[:id]
      filter.merge!(:architecture => params[:architecture]) if params[:architecture]
      filter.merge!(:owner_id => params[:owner_id]) if params[:owner_id]
      filter.merge!(:state => params[:state]) if params[:state]
      filter = nil if filter.keys.size.eql?(0)
      singular = model.to_s.singularize.to_sym
      @elements = driver.send(model.to_sym, credentials, filter)
      instance_variable_set(:"@#{model}", @elements)
      respond_to do |format|
        format.html { haml :"#{model}/index" }
        format.xml { haml :"#{model}/index" }
        format.json { convert_to_json(singular, @elements) }
      end
  end

  def show(model)
    @element = driver.send(model, credentials, { :id => params[:id]} )
    instance_variable_set("@#{model}", @element)
    if @element
      respond_to do |format|
        format.html { haml :"#{model.to_s.pluralize}/show" }
        format.xml { haml :"#{model.to_s.pluralize}/show" }
        format.json { convert_to_json(model, @element) }
      end
    else
        report_error(404, 'not_found')
    end
  end

  def report_error(status, template)
    @error = request.env['sinatra.error']
    response.status = status
    respond_to do |format|
      format.xml { haml :"errors/#{template}", :layout => false }
      format.html { haml :"errors/#{template}" }
    end
  end

  def instance_action(name)
    @instance = driver.send(:"#{name}_instance", credentials, params["id"])

    return redirect(instances_url) if name.eql?(:destroy) or @instance.class!=Instance

    respond_to do |format|
      format.html { haml :"instances/show" }
      format.xml { haml :"instances/show" }
      format.json {convert_to_json(:instance, @instance) }
    end
  end

end
