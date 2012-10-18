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

def get_current_memory_usage
  `ps -o rss= -p #{Process.pid}`.to_i
end

def profile_memory(&block)
  before = get_current_memory_usage
  file, line, _ = caller[0].split(':')
  if block_given?
    instance_eval(&block)
    puts "[#{file}:#{line}: #{(get_current_memory_usage - before) / 1024} MB (consumed)]"
  else
    before = 0
    puts "[#{file}:#{line}: #{(get_current_memory_usage - before) / 1024} MB (all)]"
  end
end
