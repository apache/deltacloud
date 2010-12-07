#
# Copyright (C) 2009,2010  Red Hat, Inc.
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

require 'base64'
require 'digest'

module MethodSerializer

  module Cache

    def cache_dir
      storage_dir = $methods_cache_dir || File.join(File.dirname(__FILE__), 'cache')
      class_dir = self.class.name.split('::').last
      class_dir ||= self.class.name
      File.join(storage_dir, class_dir.downcase)
    end

    def serialize_data(method_name, args, data)
      File.open(cache_file_name(method_name, args), 'w') do |f|
        f.puts(Base64.encode64(Marshal.dump(data)))
      end
      return data
    end

    def deserialize_data(method_name, args)
      begin
        data = File.readlines(cache_file_name(method_name, args)).join
        Marshal.load(Base64.decode64(data))
      rescue Errno::ENOENT
        return false
      end
    end

    def args_hash(args)
      if args.class == Hash
        args = args.to_a.collect {|i| [i[0].to_s, i[1]]}.sort
      end
      Digest::SHA1.hexdigest(args.to_s)
    end

    def cache_file_name(method_name, args)
      FileUtils.mkdir_p(cache_dir) unless File.directory?(cache_dir)
      method_name = $scenario_prefix ? "#{$scenario_prefix}_#{method_name}" : method_name
      File.join(cache_dir, "#{method_name}.#{args_hash(args)}")
    end

    def self.wrap_methods(c, opts={})
      $methods_cache_dir = opts[:cache_dir]
      $scenario_prefix = nil
      c.class_eval do
        cached_methods.each do |m|
          next if c.instance_methods(false).include?("original_#{m}")
          alias_method "original_#{m}".to_sym, m.to_sym
          define_method m.to_sym do |*args|
            args = args.first if args.size.eql?(1) and not args.first.class.eql?(Array)
            output = deserialize_data(m, args)
            unless output
              output = method("original_#{m}".to_sym).to_proc[args]
              return serialize_data(m, args, output)
            else
              return output
            end
          end
        end
      end
    end

  end

end
