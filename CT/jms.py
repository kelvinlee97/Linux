#!/usr/bin/env python
# -*- coding: utf-8 -*-
# Produce an Ansible Inventory file based on FrontJumpserver

import os
import sys
import re
import time
import argparse
import json
import requests
import urllib3
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

class JmsInventory(object):

    def _empty_inventory(self):
        return {"_meta": {"hostvars": {}}}

    def __init__(self):
        self.token = "435d479adcf6461e185800ba3f8191412856df77"
        self.search_key = ""
        self.jms_api_url = r'https://jump.mtchangeworld.com/api/assets/v1/assets/?search={0}'.format(self.search_key)
        self.vars_api_url = r'https://deploy.mtkefu.com/api/v1/common/deploy/frontend_vars.json'
        #self.vars_api_url = "./frontend_vars.json"
        self.inventory = self._empty_inventory()
        self.index = {}
        self.args = None
        self.parse_cli_args()
        self.cache_path_cache = "/home/deploy/frontend_deploy_script/.cache_jms"
        self.cache_path_index = "/home/deploy/frontend_deploy_script/.cache_jms_index"
        self.cache_max_age = 10
        self.all_group_vars = json.loads('{"ansible_user":"jms"}')

        # Command line argument
        if self.args.r:
            self.do_api_calls_update_cache()
        elif os.path.isfile(self.cache_path_cache) and os.path.isfile(self.cache_path_index):
            if os.path.getmtime(self.cache_path_cache) + self.cache_max_age < time.time():
                self.do_api_calls_update_cache()
        else:
            self.do_api_calls_update_cache()

        if self.args.host:
            data_to_print = self.get_host_info()
        elif self.args.list:
            if self.inventory == self._empty_inventory():
                data_to_print = self.get_inventory_from_cache()
            else:
                data_to_print = self.json_format_dict(self.inventory, True)
        print(data_to_print)


    def parse_cli_args(self):
        ''' Command line argument processing '''

        parser = argparse.ArgumentParser(
            description='Produce an Ansible Inventory file based on Jumpserver')
        parser.add_argument('--list', action='store_true', default=True,
                            help='List instances (default: True)')
        parser.add_argument('--host', action='store',
                            help='Get all the variables about a specific instance')
        parser.add_argument('--r', action='store_true', default=False,
                            help='Force refresh from to Jumpserver (default: False - use cache files)')
        self.args = parser.parse_args()


    def do_api_calls_update_cache(self):
        self.get_instances_by_jms()
        self.write_to_cache(self.inventory, self.cache_path_cache)
        self.write_to_cache(self.index, self.cache_path_index)


    def get_instances_by_jms(self):
        headers = {'accept': 'application/json'}
        api_vars = json.loads(self.api_data(self.vars_api_url, headers), encoding='utf-8')
        instances = []
        headers = {'accept': 'application/json', 'Authorization': 'Token {0}'.format(self.token)}
        instances = json.loads(self.api_data(self.jms_api_url, headers), encoding='utf-8')
        for instance in instances:
            self.add_instance_to_inventory(instance, api_vars)


    def add_instance_to_inventory(self, instance, api_vars):
        ''' Adds an instance to the inventory and index '''

        if not instance['is_active']:
            return

        if not instance['ip']:
            return

        hostname = self.to_safe(instance['hostname'])

        # add by atum (start)
        #if re.search(r'(?<=_)azure', hostname):
        #    return
        # (end)

        self.index[hostname] = [instance['id'], hostname]
        self.push(self.inventory, hostname, instance['ip'])
        group_vars = {}
        #try:
        #    #instance['comment'] = '{"test":{"dpathWeb":"101wap","spathPkg":"101-wap","dpathUnzip":"www"},"web":{"dpathWeb":"101web","spathPkg":"101web-master","dpathUnzip":"dist"}'
        #    instance['comment'] = instance['comment'].replace("'",'"')
        #    comment_vars = json.loads(instance['comment'], encoding='utf-8')
        #    group_vars = json.loads(instance['comment'], encoding='utf-8')
        #except Exception as e:
        #    pass

        sp = hostname.split('_')
        env = sp[0]
        target_group = sp[0] + '_' + sp[1]
        if (len(sp) > 2):
            group_vars = api_vars.get(target_group)
            env_group_vars = api_vars.get(env)
            self.push_group(self.inventory, target_group, hostname, group_vars)
            self.push_group(self.inventory, env, target_group, env_group_vars)
        else:
            self.push_group(self.inventory, env, hostname, None)

        self.push_group(self.inventory, 'all', env, self.all_group_vars)


    def push(self, my_dict, key, element):
        ''' Push an element into an array '''

        group_info = my_dict.setdefault(key, {})
        if isinstance(group_info, dict):
            host_list = group_info.setdefault('hosts', [])
            host_list.append(element)
        else:
            group_info.append(element)


    def push_group(self, my_dict, key, element, group_vars):
        ''' Push a group as a child of another group. '''

        parent_group = my_dict.setdefault(key, {})

        if not isinstance(parent_group, dict):
            parent_group = my_dict[key] = {'hosts': parent_group}
        child_groups = parent_group.setdefault('children', [])

        if element not in child_groups:
            child_groups.append(element)

        if group_vars:
            parent_group.setdefault('vars', group_vars)

    def jms_api_data(self):
        ''' Get instance data from Jumpserver. '''

        headers = {'accept': 'application/json',
                   'Authorization': 'Token {0}'.format(self.token)}
        response = requests.get(self.api_url, headers=headers, verify=False)
        if response.status_code != 200:
            raise Exception('[HTTP {0}]: Content: {1}'.format(response.status_code, response.content))
        return self.json_format_dict(response.json(), True)


    def api_data(self, api_url, headers):
        ''' Get instance data from Jumpserver. '''

        response = requests.get(api_url, headers=headers, verify=False)
        if response.status_code != 200:
            raise Exception('[HTTP {0}]: Content: {1}'.format(response.status_code, response.content))
        return self.json_format_dict(response.json(), True)


    def get_host_info(self):
        return None


    def get_inventory_from_cache(self):
        ''' Reads the inventory from the cache file and returns it as a JSON object '''

        cache = open(self.cache_path_cache, 'r')
        json_inventory = cache.read()
        return json_inventory


    def load_index_from_cache(self):
        ''' Reads the index from the cache file sets self.index '''

        if not os.path.isfile(self.cache_path_cache) or not os.path.isfile(self.cache_path_index):
            self.write_to_cache(self.inventory, self.cache_path_cache)
            self.write_to_cache(self.index, self.cache_path_index)
        cache = open(self.cache_path_index, 'r')
        json_index = cache.read()
        self.index = json.loads(json_index)


    def write_to_cache(self, data, filename):
        json_data = self.json_format_dict(data, True)
        cache = open(filename, 'w')
        cache.write(json_data)
        cache.close()


    def json_format_dict(self, data, pretty=False):
        if pretty:
            return json.dumps(data, sort_keys=True, indent=2, encoding='utf-8')
        else:
            return json.dumps(data, encoding='utf-8')


    def to_safe(self, word):
        regex = r"[^A-Za-z0-9\_]"
        return re.sub(regex, "_", word)


if __name__ == '__main__':
    JmsInventory()
