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

  # Used to automagically convert any XML in String
  # (like HTTP response body) to Nokogiri::XML object
  #
  # If Nokogiri::XML fails, InvalidXMLError is returned.
  #
  def to_xml
    Nokogiri::XML(self)
  end

  unless method_defined? :camelize
    def camelize
      split('_').map { |w| w.capitalize }.join
    end
  end

  unless method_defined? :pluralize
    def pluralize
      return self + 'es' if self =~ /ess$/
      return self[0, self.length-1] + "ies" if self =~ /ty$/
      return self if self =~ /data$/
      self + "s"
    end
  end

  unless method_defined? :singularize
    def singularize
      return self.gsub(/ies$/, 'y') if self =~ /ies$/
      return self.gsub(/es$/, '') if self =~ /sses$/
      self.gsub(/s$/, '')
    end
  end
end
