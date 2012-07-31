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
#

require 'rubygems'
require 'minitest/autorun'
require 'minitest/spec'
require 'xmlsimple'
require 'require_relative'

require_relative '../../../lib/deltacloud/core_ext.rb'
require_relative '../../../lib/cimi/models.rb'

DATA_DIR = File::join(File::expand_path(File::dirname(__FILE__)), 'cimi', 'data')

def parse_xml(xml, opts = {})
  opts[:force_content] = true
  opts[:keep_root] = true unless opts.has_key?(:keep_root)
  XmlSimple.xml_in(xml, opts)
end

class HashCmp
  def initialize(exp, act)
    @exp = exp
    @act = act
    @io = StringIO.new
  end

  def match?
    @equal = true
    compare_values(@exp, @act, [])
    @equal
  end

  def errors
    @io.string
  end

  private
  def compare_values(exp, act, path)
    if exp.is_a?(String)
      mismatch("entries differ", exp, act, path) unless exp == act
    elsif exp.is_a?(Array)
      mismatch("expected array", exp, act, path) unless act.is_a?(Array)
      unless act.size == exp.size
        mismatch("different array lengths", exp, act, path)
      end
      name = path.pop
      0.upto(exp.size-1) do |i|
        compare_values(exp[i], act[i], path + [ "#{name}[#{i}]" ])
      end
    elsif exp.is_a?(Hash)
      unless act.is_a?(Hash)
        mismatch("expected Hash", exp, act, path)
        return
      end
      unless (missing = exp.keys - act.keys).empty?
        error "Missing key(s) at /#{path.join("/")}: #{missing.inspect}"
      end
      unless (excess = act.keys - exp.keys).empty?
        error "Excess key(s) at /#{path.join("/")}: #{excess.inspect}"
      end
      (exp.keys - missing - excess).each do |k|
        compare_values(exp[k], act[k], path + [ k ])
      end
    end
  end

  def mismatch(msg, exp, act, path)
    error "#{msg}[#{fmt(path)}]: #{exp.inspect} != #{act.inspect}"
  end

  def error(msg)
    @equal = false
    @io.puts msg
  end

  def fmt(path)
    "/#{path.join("/")}"
  end
end

def should_properly_serialize_model(model_class, xml, json)
  # Roundtrip in same format
  model_class.from_xml(xml).must_serialize_to xml, :fmt => :xml
  model_class.from_json(json).must_serialize_to json, :fmt => :json
  # Roundtrip crossing format
  model_class.from_xml(xml).must_serialize_to json, :fmt => :json
  model_class.from_json(json).must_serialize_to xml, :fmt => :xml
end

module MiniTest::Assertions

  def assert_serialize_to(exp, act, opts)
    raise "missing format; use :fmt => [:xml || :json]" if opts[:fmt].nil?
    exp, act = [exp, act].map { |x| convert(x, opts[:fmt]) }
    m = HashCmp.new(exp, act)
    assert m.match?,  "#{opts[:fmt].to_s.upcase} documents do not match\n" + m.errors
  end

  def convert(x, fmt)
    if fmt == :json
      x = x.to_json if x.is_a?(CIMI::Model::Base)
      x = JSON.parse(x) if x.is_a?(String)
    elsif fmt == :xml
      x = x.to_xml if x.is_a?(CIMI::Model::Base)
      x = parse_xml(x)  if x.is_a?(String)
    else
      raise "Invalid format #{fmt}"
    end
    x
  end

end

CIMI::Model::Base.infect_an_assertion :assert_serialize_to, :must_serialize_to
