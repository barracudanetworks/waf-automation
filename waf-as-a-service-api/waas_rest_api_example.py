import requests
import pprint
import sys
from getpass import getpass
# Fix Python 2.x.
try: input = raw_input
except NameError: pass
try:
    from urllib.parse import urlparse
    from urllib.parse import urljoin
except ImportError:
    from urlparse import urlparse
    from urlparse import urljoin

API_BASE = "https://api.waas.barracudanetworks.com/v2/waasapi/"

def waas_api_login(email, password):
    res = requests.post(urljoin(API_BASE, 'api_login/'), data=dict(email=email, password=password))
    res.raise_for_status()
    response_json = res.json()
    return response_json['key']

def waas_api_get(token, path):
    res = requests.get(urljoin(API_BASE, path), headers={"Content-Type": "application/json", 'auth-api': token})
    res.raise_for_status()
    return res.json()

if __name__ == '__main__':
    if len(sys.argv) >= 3:
        email = sys.argv[1]
        password = sys.argv[2]
    else:
        email = input("Enter user email:")
        password = getpass("Enter user password:")
    token = waas_api_login(email, password)

# Show list of applications, and servers for each application
apps = waas_api_get(token, 'applications')
for app in apps['results']:
    #print(app['id'])
    print("Application Name/id: {} {}".format(app['name'], app['id']))
    for server in app['servers']:
        print("\tServer: {} ({} {}:{})".format(server['name'], server['protocol'], server['host'], server['port']))
