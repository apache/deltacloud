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

class String

  unless method_defined?(:classify)
    # Create a class name from string
    def classify
      self.singularize.camelize
    end
  end

  unless method_defined?(:camelize)
    # Camelize converts strings to UpperCamelCase
    def camelize
      self.to_s.gsub(/\/(.?)/) { "::#{$1.upcase}" }.gsub(/(?:^|_)(.)/) { $1.upcase }
    end
  end

  unless method_defined?(:singularize)
    # Strip 's' character from end of string
    def singularize
      self.gsub(/s$/, '')
    end
  end

  # Convert string to float if string value seems like Float
  def convert
    return self.to_f if self.strip =~ /^([\d\.]+$)/
    self
  end

  # Simply converts whitespaces and - symbols to '_' which is safe for Ruby
  def sanitize
    self.strip.gsub(/(\W+)/, '_')
  end

end
