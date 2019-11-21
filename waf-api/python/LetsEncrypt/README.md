# LetsEncrypt

This is a utility script that obtains SSL certificates from the free Let's Encrypt certificate authority and applies
them to your Web Application Firewall.  In short, this allows you to provision an HTTPS service without the effort (or
cost) of obtaining SSL certificates.

Requirements of this script:

* The script must have API access to your Web Application Firewall.
* All domains you wish to obtain certificates for must already point their DNS to your Web Application Firewall.
* Your Web Application Firewall must listen on port 80 for requests (this can be in addition to port 443).

You may obtain certificates for an unlimited number of domains.  Note that Let's Encrypt limits each certificate
to 100 domains.  If you pass in more than 100 domains, the script will request multiple certificates for you, and
configure your Web Application Firewall to use SNI (Server Name Indication) to serve the right certificate to each
HTTPS client.

Pass the following arguments to the script:

* `--waf-netloc`, `--waf-secure`, `--waf-user` and `--waf-password` tell the script how to connect to your
  Web Application Firewall.
* `--account-key` gives the script your private key.  This is used to authenticate yourself with Let's Encrypt.
  If you do not have a private key, you can generate one with: `openssl genrsa 4096 > account.key`.  This key
  is *not* the private key of your SSL certificates.
* `--waf-service` tells the script which service to use on your Web Application Firewall *to verify the requested
  domains*.  This must be the service which listens on port 80.  If you are using a Redirect Service on port 80,
  you may pass in the HTTPS service that it redirects to.
* `--waf-ssl-service` tells the script which service to apply your certificates to.  This is the service that listens
  on port 443 for the domains you are obtaining certificates for.
* `--private-key-file` tells the script which private key file you which to use for your SSL certificates.  If this file
  does not exist, the script will generate a new private key and store it here.  You can re-use the same private key
  for renewing existing certificates.
* `--domains` tells the script which domains you wish to obtain certificates for.  Pass in multiple domains as multiple
  parameters, i.e. `--domains example.com www.example.com example.co.uk www.example.co.uk`.

## Important Note: Rate Limiting

Let's Encrypt performs its own rate limiting for certificate requests.  The two most significant ones are:

* For every given top-level domain (e.g. example.com or example.co.uk), you may only obtain 20 certificates per week.
* You may only request 5 identical certificates (same domains) per week.

For this reason, do not run this script multiple times with the same set of parameters, except to renew certificates
approximately once a month.  If you are only testing, and do not need the resulting certificates to be actually trusted,
you may pass the `--staging` flag to the script, and it will use the Let's Encrypt staging environment, which is subject
to much looser rate limits.

For further information, see https://letsencrypt.org/docs/rate-limits/ .
