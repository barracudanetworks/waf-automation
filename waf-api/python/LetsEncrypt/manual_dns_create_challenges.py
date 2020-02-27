#!/usr/bin/env python
import csv
import sys
import argparse
from utils.acme_client import *

def main(argv):
    parser = argparse.ArgumentParser()
    parser.add_argument("-k", "--account-key", required=True, help="Path to your Let's Encrypt account private key")
    parser.add_argument("-D", "--domain-file", required=True, help="File to read domain(s) to create challenges for from")

    parser.add_argument("--quiet", action="store_const", const=logging.ERROR, help="Suppress output except for errors")
    parser.add_argument("--staging", action="store_true", help="Use staging instance of Let's Encrypt")

    args = parser.parse_args(argv)
    logging.getLogger().setLevel(args.quiet or logging.getLogger().level)

    client = ACMEClient(args.account_key, None, logging, STAGING_CA if args.staging else DEFAULT_CA)

    domains = []
    with open(args.domain_file, 'r') as f:
        for domain in f:
            domain = domain.strip()
            if domain:
                domains.append(domain)
    print("{} domains to process.".format(len(domains)))

    with open('dns-challenges.csv', 'w', newline='') as f:
        fields = ('domain', 'txt_record', 'txt_value', 'challenge_token', 'challenge_uri')
        writer = csv.DictWriter(f, fields)
        writer.writeheader()

        for domain in domains:
            print("{}...".format(domain))
            challenge_dict = client.verify_domain_dns_get_challenge(domain)
            if challenge_dict:
                writer.writerow(challenge_dict)
                f.flush()

if __name__ == "__main__": # pragma: no cover
    main(sys.argv[1:])
