#!/usr/bin/python
#
#  Create global ADRs to deny specific Cookie patterns and URLs to mitigate CVE-2021-26855.
#
import sys
import requests
import json
import base64

if len(sys.argv) < 3:
    print('usage: mitigate_CVE_2021_26855.py <waf_url (including port)> <username> <password>')
    sys.exit(2)

waf_url = str(sys.argv[1])
waf_login_username = str(sys.argv[2])
waf_login_password = str(sys.argv[3])

waf_rest_url=waf_url + "/restapi/v3/"
my_headers = { 'Content-Type': 'application/json'}
post_data = json.dumps({ 'username': waf_login_username, 'password': waf_login_password })
print("POST " + waf_rest_url + 'login')
try:
        r = requests.post(waf_rest_url + 'login', headers=my_headers, data=post_data )
except requests.exceptions.RequestException as e:  # This is the correct syntax
    raise SystemExit(e)
token = json.loads(r.text)['token']
token = token.encode('ascii')
b64token = base64.b64encode(token)
b64token = b64token.decode('ascii')
#
#  Create global ADRs to deny specific Cookie patterns and URLs to mitigate CVE-2021-26855.
#
adr_base_url = waf_url + "/restapi/v3/security-policies/owa/global-acls"
my_headers={"Content-Type": "application/json", "Authorization": "Basic " + b64token}
global_acl_list = []
global_acl_list.append('{"name": "Exchange-AnonCookie-CVE-2021-26855", "url": "/*", "extended-match": "(Header  Cookie rco X-AnonResource-Backend=.*\\\\/.*~.*)", "extended-match-sequence": 4, "action": "Deny and Log", "response-page": "default"}')
global_acl_list.append('{"name": "Exchange-ResourceCookie-CVE-2021-26855", "url": "/*", "extended-match": "(Header  Cookie rco X-BEResource=.*\\\\/.*~.*)", "extended-match-sequence": 5, "action": "Deny and Log", "response-page": "default"}')
global_acl_list.append('{"name": "themes-CVE-2021-26855", "url": "/owa/auth/Current/themes/resources*", "extended-match": "(Method eq POST) && (Header  User-Agent rco \\\".*(DuckDuckBot|facebookexternalhit|Baiduspider|Bingbot|Googlebot|Konqueror|Yahoo|YandexBot|antSword).*\\\")", "extended-match-sequence": 1, "action": "Deny and Log", "response-page": "default"}')
global_acl_list.append('{"name": "ecp-CVE-2021-26855", "url": "/ecp/", "extended-match": "(Method eq POST) && (Header  User-Agent rco \\\".*(ExchangeServicesClient|python-requests).*\\\")", "extended-match-sequence": 1, "action": "Deny and Log", "response-page": "default"}')
global_acl_list.append('{"name": "aspnetclient-CVE-2021-26855", "url": "/aspnet_client/", "extended-match": "(Method eq POST) && (Header  User-Agent rco \\\".*(antSword|Googlebot|Baiduspider).*\\\")", "extended-match-sequence": 1, "action": "Deny and Log", "response-page": "default"}')
global_acl_list.append('{"name": "owa-CVE-2021-26855", "url": "/owa/", "extended-match": "(Method eq POST) && (Header  User-Agent rco \\\".*(antSword|Googlebot|Baiduspider).*\\\")", "extended-match-sequence": 1, "action": "Deny and Log", "response-page": "default"}')
global_acl_list.append('{"name": "owaauth-CVE-2021-26855", "url": "/owa/auth/Current/", "extended-match": "(Method eq POST)", "extended-match-sequence": 1, "action": "Deny and Log", "response-page": "default"}')
global_acl_list.append('{"name": "ecpdefault-CVE-2021-26855", "url": "/ecp/default.flt", "extended-match": "(Method eq POST)", "extended-match-sequence": 1, "action": "Deny and Log", "response-page": "default"}')
global_acl_list.append('{"name": "ecpcss-CVE-2021-26855", "url": "/ecp/main.css", "extended-match": "(Method eq POST)", "extended-match-sequence": 1, "action": "Deny and Log", "response-page": "default"}')
for global_acl in global_acl_list:
        try:
                r = requests.post(adr_base_url, headers=my_headers, data=global_acl )
                t = r.text
                print(t)
        except requests.exceptions.RequestException as e:  # This is the correct syntax
                raise SystemExit(e)
