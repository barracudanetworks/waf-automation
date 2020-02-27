import csv
import sys
import os
import argparse
import dns.resolver
import dns.exception

from utils.acme_client import *


def test_dns(domain, txt_record, txt_value):
    try:
        qa = dns.resolver.query(txt_record, 'TXT').response.answer
    except dns.exception.DNSException as e:
        return False, "DNS Exception for {}: {} {}".format(domain, type(e), str(e))
    else:
        for answer in qa:
            for txtrecord in answer.items:
                for s in txtrecord.strings:
                    if s == txt_value:
                        print("\tFound: {}".format(s))
                        return True, None
                    else:
                        print("\tOther: {}".format(s))
        return False, "TXT record not found for {}".format(domain)


def main(argv):
    parser = argparse.ArgumentParser()
    parser.add_argument("-k", "--account-key", required=True, help="Path to your Let's Encrypt account private key")
    parser.add_argument("-D", "--challenge-file", required=True, help="File to read DNS challenges from")

    parser.add_argument("--quiet", action="store_const", const=logging.ERROR, help="Suppress output except for errors")
    parser.add_argument("--staging", action="store_true", help="Use staging instance of Let's Encrypt")

    args = parser.parse_args(argv)
    logging.getLogger().setLevel(args.quiet or logging.getLogger().level)

    client = ACMEClient(args.account_key, None, logging, STAGING_CA if args.staging else DEFAULT_CA)

    with open(args.challenge_file, 'r', newline='') as f:
        reader = csv.DictReader(f)

        with open("{}_answers{}".format(*os.path.splitext(args.challenge_file)), 'w', newline='') as out_f:
            fields = ('domain', 'txt_record', 'txt_value', 'challenge_token', 'challenge_uri', 'result', 'result_message')
            writer = csv.DictWriter(out_f, fields)
            writer.writeheader()

            for d in reader:
                print("{}...".format(d['domain']))
                # domain,txt_record,txt_value,challenge_token,challenge_uri
                new_dict = d.copy()

                # First, verify DNS is OK
                dns_ok, dns_result = test_dns(d['domain'], d['txt_record'], d['txt_value'])
                if not dns_ok:
                    print(dns_result)
                    new_dict['result'] = 'FAIL'
                    new_dict['result_message'] = dns_result
                    writer.writerow(new_dict)
                    continue

                try:
                    client.verify_domain_dns_fulfil_challenge(d['domain'], d['challenge_token'], d['challenge_uri'])
                except:
                    new_dict['result'] = 'FAIL'
                    new_dict['result_message'] = "Exception answering DNS challenge: {}".format(sys.exc_info())
                    writer.writerow(new_dict)
                    print(new_dict['result_message'])
                else:
                    new_dict['result'] = 'SUCCESS'
                    new_dict['result_message'] = ''
                    writer.writerow(new_dict)

                    print("Done.")

if __name__ == "__main__": # pragma: no cover
    main(sys.argv[1:])
