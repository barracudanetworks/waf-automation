# Manual DNS Verification

Manual DNS verification is useful if you are adding an existing domain, that already has production traffic, to your WAF.  You may want to use Let's Encrypt to obtain certificates, but there is a timing issue: you must point your A records for the new domain at the WAF to retrieve certificates; but once you do, and in the time it takes to retrieve and upload the certificate, your web clients will see a certificate error.  To work around this, you can use manual DNS verification to add domains with no downtime and no certificate warnings.

The instructions to do so are as follows:

1. Put the list of domains you wish to verify into a text file (e.g. my-domains.txt), one domain per line.
2. Run: `python3 manual_dns_create_challenges.py --account-key <account-key-file> --domain-file my-domains.txt`
3. Open up dns-challenges.csv - this will have the DNS records you need to add to each domain. You may want to download it to your PC for easier copying/pasting in Excel.  Do not modify this file.
4. Add the TXT records specified in dns-challenges.csv and wait a bit to let them propagate.
5. Run: `python3 manual_dns_answer_challenges.py dns-challenges.csv`
6. The script will attempt to verify all the domains.  Even if some fail, it will continue to try all of them.
7. Open up dns-challenges_answers.csv.  Check the "result" column for each domain to ensure it says "SUCCESS."  If any say "FAIL," check the error message and fix the DNS, then run the script again.  There is no harm in running all domains again - it will just check, see that the domain is already verified, and skip the domain.
8. Add the new domains to whatever domain list you are using for your normal certificate generation process with `get_certificates.py`.
9. Within 14 days of step 6 (but see note below), run your normal command to generate certs using `get_certificates.py`.  The script will see that the new domains are already verified, so it won't try to verify them again, and it will generate and upload the certificates for you.
10. Within 14 days of step 6 (but see note below), change your A records such that traffic for these new domains flows through the WAF.  Then, run your normal renewal command to renew the certificates.

## Important Note: Rate Limiting

Let's Encrypt performs its own rate limiting for certificate requests.  The two most significant ones are:

* For every given top-level domain (e.g. example.com or example.co.uk), you may only obtain 20 certificates per week.
* You may only request 5 identical certificates (same domains) per week.

For this reason, do not run this script multiple times with the same set of parameters, except to renew certificates
approximately once a month.  If you are only testing, and do not need the resulting certificates to be actually trusted,
you may pass the `--staging` flag to the script, and it will use the Let's Encrypt staging environment, which is subject
to much looser rate limits.

For further information, see https://letsencrypt.org/docs/rate-limits/ .