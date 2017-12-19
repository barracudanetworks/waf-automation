import urllib.parse
from urllib.parse import urljoin

import json
import requests
from requests.auth import HTTPBasicAuth

from .waf_api_errors import *
import logging


class BarracudaWAFAPI:
    """Class to access the WAF API v3"""

    def __init__(self, waf_netloc, username, password, https=False):
        """
        :param waf_netloc: FORMAT <ip/host>:<port>
        :param username:   local username for the waf
        :param password:
        """
        self.waf_netloc = waf_netloc
        self.base_url = urllib.parse.urlunparse(('https' if https else 'http', waf_netloc, '/restapi/v3/', '', '', ''))
        self.username = username
        self.password = password
        self.token = None
        self.headers = {'content-type': 'application/json'}

    @staticmethod
    def raise_for_status(response):
        if response is None:
            return

        if response.status_code not in {200, 201}:
            logging.debug("Error: {}".format(response.json().get('error')))

        if 401 == response.status_code:
            raise WAFAPILoginException(response)
        if 400 <= response.status_code < 500:
            raise WAFAPIHTTPClientError(response)
        elif 500 <= response.status_code < 600:
            raise WAFAPIHTTPServerError(response)

    def __direct_waf_login(self):
        url = urljoin(self.base_url, 'login')

        data = dict(username=self.username, password=self.password)
        res = requests.post(url, json=data, verify=False)
        BarracudaWAFAPI.raise_for_status(res)

        self.token = res.json()['token']
        logging.debug("WAF Login with '{}' to URL: {}".format(self.username, self.base_url))

    def basic_request_json(self, api_path, json_data=None, method='GET', **kwargs):
        # Log in if we haven't yet
        if not self.token:
            self.__direct_waf_login()

        url = urljoin(self.base_url, api_path)
        try:
            logging.debug("# curl -kv {} -u {} -X {} -H Content-Type:application/json -d '{}'".format(url, repr("{}:{}".format(self.token, self.username)), method.upper(), json.dumps(json_data)))
            res = requests.request(method, url, json=json_data, auth=HTTPBasicAuth(self.token, ''), headers=self.headers if json_data else None, verify=False, **kwargs)
            self.raise_for_status(res)
        except WAFAPILoginException:
            # Token probably expired - try to refresh it
            try:
                self.__direct_waf_login()
            except WAFAPIException:
                logging.info("Direct login to WAF {} failed".format(self.base_url))
                raise
            else:
                res = requests.request(method, url, json=json_data, auth=HTTPBasicAuth(self.token, ''), headers=self.headers)
                BarracudaWAFAPI.raise_for_status(res)

        return res.json()

    def create_or_update_object(self, object_path, object_name, object_data,
                                duplicate_error='duplicate value not allowed'):
        try:
            return self.basic_request_json(object_path, object_data, method='POST')
        except WAFAPIHTTPClientError as e:
            if duplicate_error in str(e).lower():
                # The object already exists - update the existing one
                return self.basic_request_json(object_path + '/' + object_name, object_data,method='PUT')
            else:
                raise

    def upload_signed_certificate(self, cert_name, private_key, certificate, intermediate_cert=None):
        new_cert = dict(name=cert_name, type='pem', key_type='rsa', assign_associated_key='no',
                        allow_private_key_export='no')
        files = [('signed_certificate', ('domain.crt', certificate, 'application/octet-stream')),
                 ('key', ('domain.key', private_key, 'application/octet-stream'))]
        if intermediate_cert:
            files.append(('intermediary_certificate', ('intermediate.crt', intermediate_cert, 'application/octet-stream')))

        res = self.basic_request_json('certificates?upload=signed', method='POST', data=new_cert, files=files)
        return res['id']
