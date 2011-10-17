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

class String
  # Rails defines this for a number of other classes, including Object
  # see activesupport/lib/active_support/core_ext/object/blank.rb
  def blank?
      self !~ /\S/
  end

  # Title case.
  #
  #   "this is a string".titlecase
  #   => "This Is A String"
  #
  # CREDIT: Eliazar Parra
  # Copied from facets
  def titlecase
    gsub(/\b\w/){ $`[-1,1] == "'" ? $& : $&.upcase }
  end

  def pluralize
    return self + 'es' if self =~ /ess$/
    self + "s"
  end

  def singularize
    return self.gsub(/es$/, '') if self =~ /sses$/
    self.gsub(/s$/, '')
  end

  def underscore
      gsub(/::/, '/').
          gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
          gsub(/([a-z\d])([A-Z])/,'\1_\2').
          tr("-", "_").
          downcase
  end


  def camelize
    gsub(/_[a-z]/) { |match| match[1].chr.upcase }
  end
end
