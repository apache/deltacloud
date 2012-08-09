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

from urlparse import urljoin

import requests


class Deltacloud:
    """Simple Deltacloud client"""

    def __init__(self, url, username, password):
        self.url = url
        self.username = username
        self.password = password
        self.entrypoints = self.discover_entrypoints()

    def request(self, path='', params=None, method='get'):
        url = urljoin(self.url, path)
        resp = requests.request(method, url,
                auth=(self.username, self.password),
                params=params,
                headers={
                    'accept': 'application/json',
                })
        return resp, resp.json

    def discover_entrypoints(self):
        status, doc = self.request('')
        links = [(link['rel'], link['href']) for link in doc['api']['link']]
        return dict(links)

    def hardware_profiles(self):
        status, doc = self.request(self.entrypoints['hardware_profiles'])
        return [HardwareProfile(self, profile) for profile in
                get_in_dict(doc, ['hardware_profiles', 'hardware_profile'], [])]

    def realms(self):
        status, doc = self.request(self.entrypoints['realms'])
        return [Realm(self, realm) for realm in
                get_in_dict(doc, ['realms','realm'], [])]

    def images(self):
        status, doc = self.request(self.entrypoints['images'])
        return [Image(self, image) for image in
                get_in_dict(doc, ['images', 'image'], [])]

    def instances(self):
        status, doc = self.request(self.entrypoints['instances'])
        return [Instance(self, instance) for instance in
                get_in_dict(doc, ['instances', 'instance'], [])]

    def create_instance(self, image_id, opts=None):
        if opts is None:
            opts = {}
        opts['image_id'] = image_id
        response, doc = self.request(self.entrypoints['instances'], opts, 'post')
        instance = get_in_dict(doc, ['instance'])
        return Instance(self, instance)

def get_in_dict(dictionary, path, default=None):
    '''
    Return the value at the path in the nested dictionary.

    If the path isn't available, return the default value instead.
    '''
    if not path:
        return default
    if not dictionary:
        return default
    if len(path) == 1:
        return dictionary.get(path[0], default)
    return get_in_dict(dictionary.get(path[0], {}), path[1:], default)

class Instance(Deltacloud):

    def __init__(self, deltacloud, instance):
        self.instance, self.deltacloud = instance, deltacloud
        self.id = instance["id"]
        self.name = instance["name"]
        self.state = instance["state"]
        self.owner_id = instance["owner_id"]

        self.public_addresses = [instance['public_addresses']['address']]
        self.private_addresses = [instance['private_addresses']['address']]

        auth_type = get_in_dict(instance, ['authentication', 'type'])
        login = get_in_dict(instance, ['authentication', 'login'], {})
        if auth_type == 'key':
            self.key_name = login.get('keyname')
        if auth_type == 'password':
            self.username = login.get('username')
            self.password = login.get('password')

    def start(self):
        return self.do_action('start')

    def stop(self):
        return self.do_action('stop')

    def reboot(self):
        return self.do_action('reboot')

    def destroy(self):
        return self.do_action('destroy')

    def actions(self):
        '''Return all the actions allowed on the instance.'''
        return [link['rel'] for link in
                get_in_dict(self.instance, ['actions', 'link'], [])]

    def do_action(self, action):
        '''Run the specified action.'''
        if not action in self.actions():
            return False
        action_links = [link for link in
                        get_in_dict(self.instance, ['actions', 'link'], [])
                        if link['rel'] == action]
        action = action_links[0]
        url = action['href']
        method = action['method']
        response, body = self.deltacloud.request(url, method=method)
        if response.status_code >= 400:
            return False
        if body and 'instance' in body:
            self.instance = body['instance']
        return True


class Image(Deltacloud):

    def __init__(self, client, image):
        self.id = image["id"]
        self.name = image["name"]
        self.state = image["state"]
        self.owner_id = image["owner_id"]
        self.architecture = image["architecture"]
        self.description = image["description"]


class Realm(Deltacloud):

    def __init__(self, client, realm):
        self.id = realm['id']
        self.name = realm['name']
        self.state = realm['state']


class HardwareProfile(Deltacloud):

    def __init__(self, client, profile):
        self.id = profile['id']
        self.name = profile['name']
        self.properties = [HardwareProfileProperty(profile, prop) for prop in
                           profile.get('property', [])]


class HardwareProfileProperty(HardwareProfile):

    def __init__(self, profile, prop):
        self.name  = prop['name']
        self.kind  = prop['kind']
        self.unit  = prop['unit']
        self.value = prop['value']
        if 'enum' in prop:
            self.enums = [enum['value'] for enum in prop['enum']['entry']]
        if 'range' in prop:
            self.range_min = prop['range']['first']
            self.range_max = prop['range']['last']
