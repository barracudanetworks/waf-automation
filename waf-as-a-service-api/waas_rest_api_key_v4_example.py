
import requests
import json
import sys
from urllib.parse import urljoin

API_BASE = "https://api.waas.barracudanetworks.com/v4/waasapi/"


def waas_api_get(token, path):
    res = requests.get(urljoin(API_BASE, path), headers={"Content-Type": "application/json", "Authorization": f"Bearer {token}"})
    res.raise_for_status()
    return res.json()


def waas_api_patch(token, path, data):
    res = requests.patch(urljoin(API_BASE, path), data, headers={"Authorization": f"Bearer {token}"})
    res.raise_for_status()
    return res.json()


if __name__ == '__main__':
    if len(sys.argv) >= 2:
        token = sys.argv[1]
    else:
        token = input("Enter API Token:")

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
