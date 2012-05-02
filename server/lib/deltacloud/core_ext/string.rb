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
    return self[0, self.length-1] + "ies" if self =~ /ty$/
    return self if self =~ /data$/
    self + "s"
  end

  def singularize
    return self.gsub(/es$/, '') if self =~ /sses$/
    self.gsub(/s$/, '')
  end

  def underscore
    return self.downcase if self =~ /VSPs$/i
    gsub(/::/, '/').
    gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
    gsub(/([a-z\d])([A-Z])/,'\1_\2').
    tr("-", "_").
    downcase
  end

  def camelize(lowercase_first_letter=nil)
    s = split('_').map { |w| w.capitalize }.join
    lowercase_first_letter ? s.uncapitalize : s
  end

  def uncapitalize
    self[0, 1].downcase + self[1..-1]
  end

  def upcase_first
    self[0, 1].upcase + self[1..-1]
  end

  def truncate(length = 10)
    return self if self.length <= length
    end_string = "...#{self[(self.length-(length/2))..self.length]}"
    "#{self[0..(length/2)]}#{end_string}"
  end

  unless "".respond_to? :each
    alias :each :each_line
  end

end
