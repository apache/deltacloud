# Copyright (C) 2009, 2010  Red Hat, Inc.
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

from httplib2 import Http
from urllib import urlencode
import libxml2

class SimpleRestClient:
    """A simple REST client library"""

    def __init__(self, api_url, api_user, api_password):
      self.url, self.user, self.password = api_url, api_user, api_password
      self.client = Http()
      self.client.follow_all_redirect = True
      self.client.add_credentials(self.user, self.password)

    def GET(self, uri):
      if uri.startswith('http://'):
        current_url = ''
      else:
        current_url = self.url
      status, response = self.client.request('{url}{uri}'.format(url=current_url, uri=uri), 'GET', headers={'accept':'application/xml'})
      response = self.parse_xml(response)
      return status, response

    def POST(self, uri, params={}):
      if uri.startswith('http://'):
        current_url = ''
      else:
        current_url = self.url
      if not params:
        params = {}
      status, response = self.client.request('{url}{uri}'.format(url=current_url, uri=uri), 'POST',
          urlencode(params), headers={'accept':'application/xml'})
      response = self.parse_xml(response)
      return status, response

    def DELETE(self, uri):
      if uri.startswith('http://'):
        current_url = ''
      else:
        current_url = self.url
      return self.client.request('{url}{uri}'.format(url=current_url, uri=uri), 'DELETE')

    def PUT(self, uri):
      if uri.startswith('http://'):
        current_url = ''
      else:
        current_url = self.url
      return self.client.request('{url}{uri}'.format(url=current_url, uri=uri), 'PUT')

    def parse_xml(self, response):
      return libxml2.parseDoc(response)


class Deltacloud:
  """ Simple Deltacloud client """

  def __init__(self, url, username, password):
    self.client = SimpleRestClient(url, username, password)
    self.entrypoints = self.discover_entrypoints()

  def discover_entrypoints(self):
    doc = self.client.GET('/')[1]
    entrypoints = {}
    for link in doc.xpathEval("/api/link"):
      entrypoints[link.xpathEval("@rel")[0].content] = link.xpathEval("@href")[0].content
    return entrypoints

  def hardware_profiles(self):
    doc = self.client.GET(self.entrypoints['hardware_profiles'])[1]
    profiles = []
    for profile in doc.xpathEval("/hardware_profiles/hardware_profile"):
      profiles.append(HardwareProfile(self, profile))
    return profiles

  def realms(self):
    doc = self.client.GET(self.entrypoints['realms'])[1]
    realms = []
    for realm in doc.xpathEval("/realms/realm"):
      realms.append(Realm(self, realm))
    return realms

  def images(self):
    doc = self.client.GET(self.entrypoints['images'])[1]
    images = []
    for image in doc.xpathEval("/images/image"):
      images.append(Image(self, image))
    return images

  def instances(self):
    doc = self.client.GET(self.entrypoints['instances'])[1]
    instances = []
    for instance in doc.xpathEval("/instances/instance"):
      instances.append(Instance(self, instance))
    return instances

  def create_instance(self, image_id, opts):
    #if opts is None:
    #  opts={}
    opts['image_id'] = image_id
    doc = self.client.POST(self.entrypoints['instances'], opts)[1]
    instance = doc.xpathEval("/instance")[0]
    return Instance(self, instance)


class Instance(Deltacloud):

  def __init__(self, deltacloud, instance):
    print instance
    self.instance, self.deltacloud = instance, deltacloud
    self.id = instance.xpathEval("@id")[0].content
    self.name = instance.xpathEval("name")[0].content
    self.state = instance.xpathEval("state")[0].content
    self.owner_id = instance.xpathEval("owner_id")[0].content
    self.public_addresses, self.private_addresses = [], []
    [self.public_addresses.append(address.content) for address in instance.xpathEval('public_addresses/address')]
    [self.private_addresses.append(address.content) for address in instance.xpathEval('private_addresses/address')]
    password_auth = instance.xpathEval("authentication[@type='password']/login")
    key_auth = instance.xpathEval("authentication[@type='key']/login")
    if password_auth:
      self.username = password_auth[0].xpathEval('username')[0].content
      self.password = password_auth[0].xpathEval('password')[0].content
    if key_auth:
      self.key_name = key_auth[0].xpathEval('keyname').content

  def start(self):
    action = self.instance.xpathEval("actions/link[@rel='start']")
    if not action:
      return False
    else:
      if self.deltacloud.client.POST(action[0].xpathEval("@href")[0].content, {})[0]['status'] == '200':
        return True
      else:
        return False

  def stop(self):
    action = self.instance.xpathEval("actions/link[@rel='stop']")
    if not action:
      return False
    else:
      if self.deltacloud.client.POST(action[0].xpathEval("@href")[0].content, {})[0]['status'] == '200':
        return True
      else:
        return False

  def reboot(self):
    action = self.instance.xpathEval("actions/link[@rel='reboot']")
    if not action:
      return False
    else:
      if self.deltacloud.client.POST(action[0].xpathEval("@href")[0].content, {})[0]['status'] == '200':
        return True
      else:
        return False

  def destroy(self):
    action = self.instance.xpathEval("actions/link[@rel='destroy']")
    if not action:
      return False
    else:
      if self.deltacloud.client.POST(action[0].xpathEval("@href")[0].content, {})[0]['status'] == '200':
        return True
      else:
        return False


class Image(Deltacloud):

  def __init__(self, client, image):
    self.id = image.xpathEval("@id")[0].content
    self.name = image.xpathEval("name")[0].content
    self.state = image.xpathEval("state")[0].content
    self.owner_id = image.xpathEval("owner_id")[0].content
    self.architecture = image.xpathEval("architecture")[0].content
    self.description = image.xpathEval("description")[0].content

class Realm(Deltacloud):

  def __init__(self, client, realm):
    self.id = realm.xpathEval("@id")[0].content
    self.name = realm.xpathEval("name")[0].content
    self.state = realm.xpathEval("state")[0].content


class HardwareProfile(Deltacloud):

  def __init__(self, client, profile):
    self.id = profile.xpathEval("@id")[0].content
    self.name = profile.xpathEval("name")[0].content
    self.properties = []
    for prop in profile.xpathEval("property"):
      self.properties.append(HardwareProfileProperty(profile, prop))

class HardwareProfileProperty(HardwareProfile):

  def __init__(self, profile, prop):
    self.name  = prop.xpathEval("@name")[0].content
    self.kind  = prop.xpathEval("@kind")[0].content
    self.unit  = prop.xpathEval("@unit")[0].content
    self.value = prop.xpathEval("@value")[0].content
    if prop.xpathEval("enum"):
      self.enums = []
      [self.enums.append(attr.content) for attr in prop.xpathEval('enum/entry')]
    if prop.xpathEval("range"):
      self.range_min = prop.xpathEval('range/@first')[0].content
      self.range_max = prop.xpathEval('range/@last')[0].content
