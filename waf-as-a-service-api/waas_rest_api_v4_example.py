
import requests
import json
import sys
from getpass import getpass
from urllib.parse import urljoin

API_BASE = "https://api.waas.barracudanetworks.com/v4/waasapi/"


def waas_api_login(email, password):
    res = requests.post(urljoin(API_BASE, 'api_login'), data=dict(email=email, password=password))
    res.raise_for_status()
    response_json = res.json()
    return response_json['key']


def waas_api_get(token, path):
    res = requests.get(urljoin(API_BASE, path), headers={"Content-Type": "application/json", 'auth-api': token})
    res.raise_for_status()
    return res.json()


def waas_api_patch(token, path, data):
    res = requests.patch(urljoin(API_BASE, path), data, headers={'auth-api': token})
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
    for app in apps:
        print("Application Name: {}".format(app['name']))
        for server in app['servers']:
            print("\tServer: {} ({} {}:{})".format(server['name'], server['protocol'], server['host'], server['port']))

    if apps:
        app_name = apps[0]['name']
        # change request limits value
        data = {"max_request_length": 3141}
        updated = waas_api_patch(token, urljoin(API_BASE, f'applications/{app_name}/request_limits/'), data)

        print('updated request limits:', json.dumps(updated, indent=4))
