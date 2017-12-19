#!/usr/bin/env python
import argparse, subprocess, json, os, sys, base64, binascii, time, hashlib, re, copy, textwrap, logging
import pprint, tempfile, contextlib
from urllib.request import urlopen

from utils.waf_direct_api import BarracudaWAFAPI
from utils.acme_client import ACMEClient

class DomainVerifierBarracudaWAF:
    def __init__(self, waf_api, service_name):
        self.waf_api = waf_api
        self.service_name = service_name

    @contextlib.contextmanager
    def verify_domain(self, domain, token, path, file_contents):
        # TODO: Check if the service is in passive mode.  If so, this won't work.  A possible workaround is to create
        # a Content Rule that overrides the mode to active only for our path.

        # Create a response page that returns the verification contents
        # (Advanced->Libraries->Response Page in UI)
        response_page_name = 'LetsEncrypt-verification'
        response_page = {
            'body': file_contents,
            'headers': ['Connection:Close &lt;br&gt;Content-Type:text/plain'],
            'name': response_page_name,
            'status-code': '200 OK',
            'type': 'Other Pages'}
        self.waf_api.create_or_update_object('response-pages', response_page_name, response_page)

        # Create an Allow/Deny rule that responds with this page when the verification path is requested
        # (Websites->Allow/Deny in UI)
        acl_name = 'LetsEncrypt-verification'
        acl = {'action': 'Deny and Log',
               'comments': '',
               'deny-response': 'Response Page',
               'enable': 'On',
               'extended-match': '*',
               'extended-match-sequence': '1',
               'follow-up-action': 'None',
               'follow-up-action-time': '60',
               'host': '*',
               'name': acl_name,
               'redirect-url': '',
               'response-page': response_page_name,
               'url': path}
        self.waf_api.create_or_update_object('services/{}/url-acls'.format(self.service_name), acl_name, acl)

        yield

        self.waf_api.basic_request_json('services/{}/url-acls/{}'.format(self.service_name, acl_name), method='DELETE')
        self.waf_api.basic_request_json('response-pages/' + response_page_name, method='DELETE')


def apply_certificate_to_waf_service(waf_api, service_name, cert_name, private_key_file, certificate, intermediate_cert):
    with open(private_key_file, 'r') as f:
        private_key = f.read()

    waf_api.upload_signed_certificate(cert_name, private_key, certificate, intermediate_cert)

    res = waf_api.basic_request_json('services/{}/ssl-security'.format(service_name))
    ssl_data = res['data'][service_name]['SSL Security']
    ssl_data['certificate'] = cert_name
    # Explicitly disable SNI and blank out its fields.  This is a workaround for BNWF-28055.
    ssl_data['enable-sni'] = 'No'
    ssl_data['domain'] = []
    ssl_data['sni-certificate'] = []
    waf_api.basic_request_json('services/{}/ssl-security'.format(service_name), ssl_data, method='PUT')


def apply_certificates_to_waf_service_with_sni(waf_api, service_name, certificates):
    """
    Applies a set of certificates to a WAF service, with each certificate being used for its valid domains.

    :param waf_api: WAF API.
    :param service_name: Name of the service to update certificates for.
    :param certificates: A list of certificates.  Each certificate should be a dict with the following values:
     * name - name of the certificate on the WAF
     * cert - certificate text (PEM encoded)
     * domains (optional) - list of domains this certificate covers.  If not provided, will be read from the certificate.
    """

    # The WAF accepts SNI as a list of domains and a list of certs, both of the same length.  Each domain will use
    # the cert in the same index of the cert list.
    domain_list = []
    cert_list = []

    for cert_dict in certificates:
        if 'domains' not in cert_dict:
            with ACMEClient.tempfile(cert_dict['cert']) as cert_file:
                cert_dict['domains'] = ACMEClient.get_domains_from_cert(cert_file)

        domain_list += cert_dict['domains']
        cert_list += [cert_dict['name']] * len(cert_dict['domains'])
    assert len(domain_list) == len(cert_list)

    res = waf_api.basic_request_json('services/{}/ssl-security'.format(service_name))
    ssl_data = res['data'][service_name]['SSL Security']
    ssl_data['enable-sni'] = 'Yes'
    ssl_data['domain'] = domain_list
    ssl_data['sni-certificate'] = cert_list
    waf_api.basic_request_json('services/{}/ssl-security'.format(service_name), ssl_data, method='PUT')

