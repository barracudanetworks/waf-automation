#!/usr/bin/env python
"""
Allows you to obtain certificates from Let's Encrypt (https://letsencrypt.org/) for domains hosted on a Barracuda
Web Application Firewall.  Automatically answers Let's Encrypt's challenges using the Web Application Firewall.
"""
import argparse, subprocess, json, os, sys, base64, binascii, time, hashlib, re, copy, textwrap, logging
import pprint, tempfile, contextlib
from urllib.request import urlopen

from utils.waf_direct_api import BarracudaWAFAPI
from utils.waf_acme import DomainVerifierBarracudaWAF, apply_certificate_to_waf_service, apply_certificates_to_waf_service_with_sni
from utils.acme_client import ACMEClient, INTERMEDIATE_CERT, DEFAULT_CA, STAGING_CA

MAX_DOMAINS_PER_CERT = 100  # See https://letsencrypt.org/docs/rate-limits/

LOGGER = logging
logging.basicConfig(level=logging.DEBUG)

def chunks(iterable, n):
    """Yield successive n-sized chunks from iterable."""
    values = []
    for i, item in enumerate(iterable, 1):
        values.append(item)
        if i % n == 0:
            yield values
            values = []
    if values:
        yield values

def main(argv):
    parser = argparse.ArgumentParser()
    parser.add_argument("-k", "--account-key", required=True, help="Path to your Let's Encrypt account private key")
    parser.add_argument("-w", "--waf-netloc", required=True, help="WAF netloc, in the format <host>[:<port>]")
    parser.add_argument("-S", "--waf-secure", action='store_true', default=False, help="Connect to WAF using HTTPS")
    parser.add_argument("-u", "--waf-user", required=True, help="Login username to your WAF")
    parser.add_argument("-p", "--waf-password", required=True, help="Login password to your WAF")
    parser.add_argument("-s", "--waf-service", required=True, help="Service on your WAF to verify with")
    parser.add_argument("-d", "--domains", nargs="+", required=True, help="List of domain(s) to verify")
    parser.add_argument("--private-key-file", default="domain.key", help="File in which to place/read private key for cert")
    parser.add_argument("--waf-ssl-service", help="Service on WAF to upload resulting SSL certificate to")
    parser.add_argument("--verify-only", action='store_true', default=False, help="Dry run; verify domains but don't generate certificate")

    parser.add_argument("--quiet", action="store_const", const=logging.ERROR, help="Suppress output except for errors")
    parser.add_argument("--staging", action="store_true", help="Use staging instance of Let's Encrypt")

    args = parser.parse_args(argv)
    logging.getLogger().setLevel(args.quiet or logging.getLogger().level)

    waf_api = BarracudaWAFAPI(args.waf_netloc, args.waf_user, args.waf_password, args.waf_secure)
    verifier = DomainVerifierBarracudaWAF(waf_api, args.waf_service)
    client = ACMEClient(args.account_key, verifier, logging, STAGING_CA if args.staging else DEFAULT_CA)

    if args.verify_only:
        for domain in args.domains:
            client.verify_domain(domain)
        sys.exit(0)

    if len(args.domains) <= MAX_DOMAINS_PER_CERT:
        # Get a single cert for all the domains and apply it to the WAF.
        with client.tempfile(None) as csr_file:
            with client.tempfile(None) as cert_file:
                certificate = client.get_certificate_for_domains(args.domains, args.private_key_file, csr_file, cert_file)

                if args.waf_ssl_service:
                    # Note: cert name can't start with a number, so prepend 'acme_'.
                    serial_number = 'acme_' + client.get_serial_number_from_certificate(cert_file)
                    apply_certificate_to_waf_service(waf_api, args.waf_ssl_service, serial_number, args.private_key_file,
                                                     certificate, INTERMEDIATE_CERT)
    else:
        # Too many domains for a single certificate.  Get multiple certificates, and apply them to the WAF using SNI.
        with open(args.private_key_file, 'r') as f:
            private_key = f.read()

        certs = []

        # Get separate certs for each chunk of domains
        for cert_domains in chunks(args.domains, MAX_DOMAINS_PER_CERT):
            logging.info("Getting certificate for domains: {}".format(cert_domains))
            with client.tempfile(None) as csr_file:
                with client.tempfile(None) as cert_file:
                    certificate = client.get_certificate_for_domains(cert_domains, args.private_key_file, csr_file, cert_file)
                    # Note: cert name can't start with a number, so prepend 'acme_'.
                    serial_number = 'acme_' + client.get_serial_number_from_certificate(cert_file)
                    waf_api.upload_signed_certificate(serial_number, private_key, certificate, INTERMEDIATE_CERT)
                    certs.append(dict(name=serial_number, cert=certificate, domains=cert_domains))

        if args.waf_ssl_service:
            apply_certificates_to_waf_service_with_sni(waf_api, args.waf_ssl_service, certs)


if __name__ == "__main__": # pragma: no cover
    main(sys.argv[1:])
