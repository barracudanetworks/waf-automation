# example of POST to create a URL allow-deny rule with an extended match
import requests
import pprint
import sys
from getpass import getpass
try:
        from urllib.parse import urlparse
        from urllib.parse import urljoin
except ImportError:
        from urlparse import urlparse
        from urlparse import urljoin

API_BASE = "https://api.waas.barracudanetworks.com/v2/waasapi/"

#optional: uses mitm proxy for debugging
proxies = {
 'http': 'http://127.0.0.1:8080',
 'https': 'http://127.0.0.1:8080',
}

def waas_api_login(email, password):
        res = requests.post(urljoin(API_BASE, 'api_login/'), data=dict(email=email, password=password), proxies=proxies)
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
        print("Application: {} {}".format(app['name'],app['id']))
        for server in app['servers']:
                print("\tServer: {} ({} {}:{})".format(server['name'], server['protocol'], server['host'], server['port']))

url_allow_deny = "{ \"enabled\": true, \"name\": \"deny-my-url\", \"deny_response\": \"Response Page\", \"response_page\": \"default\", \"action\": \"Process\", \"url_match\": \"/forbidden/to/post/here/*\", \"follow_up_action_time\": 1, \"host_match\": \"*\", \"allow_deny_rule\": \"string\", \"redirect_url\": \"string\", \"extended_match\": \"(Method eq POST) && (Header  User-Agent rco \\\".*(DuckDuckBot|facebookexternalhit|Baiduspider|Bingbot|Googlebot|Konqueror|Yahoo|YandexBot|antSword).*\\\")\", \"follow_up_action\": \"None\", \"priority\": 3}"
# Post to the last application, creating a url allow-deny rule with an extended match
waas_api_post(token, 'https://api.waas.barracudanetworks.com/v2/waasapi/applications/' + str(app['id']) + '/allow_deny/urls/', url_allow_deny)
