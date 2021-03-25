wafaas_exchange.py                 wafaas_mitigate_CVE_2021_26855.py
[centos@ip-10-0-1-234 exchange]$ cat wafaas_mitigate_CVE_2021_26855.py
import requests
import pprint
import sys
import sys
from getpass import getpass
try:
        from urllib.parse import urlparse
        from urllib.parse import urljoin
except ImportError:
        from urlparse import urlparse
        from urlparse import urljoin

python_major_version = sys.version_info[0]
python_minor_version = sys.version_info[1]

API_BASE = "https://api.waas.barracudanetworks.com/v2/waasapi/"

proxies = { 'http': 'http://127.0.0.1:8080', 'https': 'http://127.0.0.1:8080', }
proxies = ''

def waas_api_login(email, password):
        res = requests.post(urljoin(API_BASE, 'api_login/'), data=dict(email=email, password=password), proxies=proxies)
        #res = requests.post(urljoin(API_BASE, 'api_login/'), data=dict(email=email, password=password))
        res.raise_for_status()
        response_json = res.json()
        return response_json['key']

def waas_api_get(token, path):
        res = requests.get(urljoin(API_BASE, path), headers={"Content-Type": "application/json", 'auth-api': token}, proxies=proxies)
        res.raise_for_status()
        return res.json()

def waas_api_post(token, path, mydata):
        res = requests.post(urljoin(API_BASE, path), headers={"Content-Type": "application/json", "Accept": "application/json",'auth-api': token}, data=mydata, proxies=proxies)
        print(res.json())
        res.raise_for_status()
        return res.json()

if __name__ == '__main__':
        if len(sys.argv) >= 4:
                email = sys.argv[1]
                password = sys.argv[2]
                application_name = sys.argv[3]
        else:
                if python_major_version == 2:
                        email = raw_input("Enter user email:")
                elif python_major_version == 3:
                        email = input("Enter user email:")
                else:
                        assert("You are not using Python version 2 nor 3, so this script cannot continue.");

                password = getpass("Enter user password:")

                if python_major_version == 2:
                        application_name = raw_input("Enter application name:")
                elif python_major_version == 3:
                        application_name = input("Enter application name:")
                else:
                        assert("You are not using Python version 2 nor 3, so this script cannot continue.");

        token = waas_api_login(email, password)

url_allow_deny_list = []
url_allow_deny_list.append('{ "enabled": true, "name": "Exchange-AnonCookie-CVE-2021-26855", "deny_response": "Response Page", "response_page": "default", "action": "Deny and Log", "url_match": "/*", "follow_up_action_time": 1, "host_match": "*", "allow_deny_rule": "string", "redirect_url": "string", "extended_match": "(Header  Cookie rco X-AnonResource-Backend=.*\\\\/.*~.*)", "follow_up_action": "None", "priority": 1}')
url_allow_deny_list.append('{ "enabled": true, "name": "Exchange-ResourceCookie-CVE-2021-26855", "deny_response": "Response Page", "response_page": "default", "action": "Deny and Log", "url_match": "/*", "follow_up_action_time": 1, "host_match": "*", "allow_deny_rule": "string", "redirect_url": "string", "extended_match": "(Header  Cookie rco X-BEResource=.*\\\\/.*~.*)", "follow_up_action": "None", "priority": 2}')
url_allow_deny_list.append('{ "enabled": true, "name": "themes-CVE-2021-26855", "deny_response": "Response Page", "response_page": "default", "action": "Deny and Log", "url_match": "/owa/auth/Current/themes/resources/*", "follow_up_action_time": 1, "host_match": "*", "allow_deny_rule": "string", "redirect_url": "string", "extended_match": "(Method eq POST) && (Header  User-Agent rco \\".*(DuckDuckBot|facebookexternalhit|Baiduspider|Bingbot|Googlebot|Konqueror|Yahoo|YandexBot|antSword).*\\")", "follow_up_action": "None", "priority": 1}')
url_allow_deny_list.append('{ "enabled": true, "name": "ecp-CVE-2021-26855", "deny_response": "Response Page", "response_page": "default", "action": "Deny and Log", "url_match": "/ecp/", "follow_up_action_time": 1, "host_match": "*", "allow_deny_rule": "string", "redirect_url": "string", "extended_match": "(Method eq POST) && (Header  User-Agent rco \\".*(ExchangeServicesClient|python-requests).*\\")", "follow_up_action": "None", "priority": 1}')
url_allow_deny_list.append('{ "enabled": true, "name": "aspnetclient-CVE-2021-26855", "deny_response": "Response Page", "response_page": "default", "action": "Deny and Log", "url_match": "/aspnet_client/", "follow_up_action_time": 1, "host_match": "*", "allow_deny_rule": "string", "redirect_url": "string", "extended_match": "(Method eq POST) && (Header  User-Agent rco \\".*(antSword|Googlebot|Baiduspider).*\\")", "follow_up_action": "None", "priority": 1}')
url_allow_deny_list.append('{ "enabled": true, "name": "owa-CVE-2021-26855", "deny_response": "Response Page", "response_page": "default", "action": "Deny and Log", "url_match": "/owa/", "follow_up_action_time": 1, "host_match": "*", "allow_deny_rule": "string", "redirect_url": "string", "extended_match": "(Method eq POST) && (Header  User-Agent rco \\".*(antSword|Googlebot|Baiduspider).*\\")", "follow_up_action": "None", "priority": 1}')
url_allow_deny_list.append('{ "enabled": true, "name": "owaauth-CVE-2021-26855", "deny_response": "Response Page", "response_page": "default", "action": "Deny and Log", "url_match": "/owa/auth/Current/", "follow_up_action_time": 1, "host_match": "*", "allow_deny_rule": "string", "redirect_url": "string", "extended_match": "(Method eq POST)", "follow_up_action": "None", "priority": 1}')url_allow_deny_list.append('{ "enabled": true, "name": "ecpdefault-CVE-2021-26855", "deny_response": "Response Page", "response_page": "default", "action": "Deny and Log", "url_match": "/ecp/default.flt", "follow_up_action_time": 1, "host_match": "*", "allow_deny_rule": "string", "redirect_url": "string", "extended_match": "(Method eq POST)", "follow_up_action": "None", "priority": 1}')
url_allow_deny_list.append('{ "enabled": true, "name": "ecpcss-CVE-2021-26855", "deny_response": "Response Page", "response_page": "default", "action": "Deny and Log", "url_match": "/ecp/main.css", "follow_up_action_time": 1, "ho st_match": "*", "allow_deny_rule": "string", "redirect_url": "string", "extended_match": "(Method eq POST)", "follow_up_action": "None", "priority": 1}')

# apply url_allow_deny for all applications
#
apps = waas_api_get(token, 'applications')
for app in apps['results']:
        if(app['name'] == application_name):
                print("Application: {} {}".format(app['name'],app['id']))
                for url_allow_deny in url_allow_deny_list:
                        try:
                                waas_api_post(token, 'applications/' + str(app['id']) + '/allow_deny/urls/', url_allow_deny)
                        except requests.exceptions.RequestException as e:
                                print("If you get an error about a Unique Set, it may mean you already ran this script so check your application in the GUI.")
                                raise SystemExit(e)
[centos@ip-10-0-1-234 exchange]$
