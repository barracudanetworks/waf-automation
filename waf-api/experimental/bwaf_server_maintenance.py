#!/usr/bin/python

import sys
import requests
import json
import base64

if len(sys.argv) < 6:
    print('usage: bwaf_server_change.py <waf_url (including port)> <username> <password> <server ip> <server port> <action {"In Service" | "Out of Service Maintenance"} >')
    sys.exit(2)
    

waf_url = str(sys.argv[1])
waf_login_username = str(sys.argv[2])
waf_login_password = str(sys.argv[3])
svr_ip   = str(sys.argv[4])
svr_port = str(sys.argv[5])
svr_status = str(sys.argv[6])

waf_rest_url=waf_url + "/restapi/v3.1/"
hhh = { 'Content-Type': 'application/json'}
post_data = json.dumps({ 'username': waf_login_username, 'password': waf_login_password })
print("POST " + waf_rest_url + 'login')
r = requests.post(waf_rest_url + 'login', headers=hhh, data=post_data )
token = json.loads(r.text)['token']
token = token.encode('ascii')
b64token = base64.b64encode(token)
b64token = b64token.decode('ascii')
hhh={"Content-Type": "application/json", "Authorization": "Basic " + b64token}
print("GET " + waf_rest_url + 'services?parameters=name')
r = requests.get(waf_rest_url + 'services?parameters=name', headers=hhh )
t = r.text
j = json.loads(t)
services = j["data"]
for service in services:
    print("=================START SERVICE " + service + "==========================")
    print(service)
    print("GET " + waf_rest_url + "services/" + service + '/servers?parameters=name,ip-address,port,status')
    r = requests.get(waf_rest_url + "services/" + service + '/servers?parameters=name,ip-address,port,status', headers=hhh )
    t = r.text
    j = json.loads(t)
    #sys.exit()
    servers = j["data"]
    #print(servers)
    for server in servers:
        print("-> " + server)
        s = servers[server]
        for detail in s:
            print("  -> " + detail + " : " + s[detail])
        if s["ip-address"] == svr_ip and s["port"] == svr_port and s["status"] != svr_status:
            post_data = json.dumps({ 'status': svr_status} )
            print("      PUT " + waf_rest_url + "services/" + service + '/servers/' + server + " " + post_data)
            r = requests.put(waf_rest_url + "services/" + service + '/servers/' + server, headers=hhh, data=post_data )
            t = r.text
            print("      -> " + json.loads(t)["msg"])

    print("        GET " + waf_rest_url + "services/" + service + '/content-rules?parameters=name')
    r = requests.get(waf_rest_url + "services/" + service + '/content-rules', headers=hhh )
    t = r.text
    j = json.loads(t)
    #sys.exit()
    #print(t)
    rules = "brettw"
    try:
        rules = j["data"]
    except:
        print("--- (no rules) ---")
    if rules != "brettw":
        for rule in rules:
            #print(rule)
            print("-----------------------------------start rule " + rule + "-------------------------------------")
            x = rules[rule]
            y = x["Rule Group Server"]
            z = y["data"]
            #print(z)
            for h in z:
                #print(h)
                rule_server = z[h]
                #print(rule_server)
                rule_svr_ip = rule_server["ip-address"]
                rule_svr_port = rule_server["port"]       
                rule_svr_name = rule_server["name"]
                rule_svr_status = rule_server["status"]
                print("       server name: " + rule_svr_name + " ip: " + rule_svr_ip + " port: " + rule_svr_port + " status: " + rule_svr_status)
                if rule_svr_ip == svr_ip and rule_svr_port == svr_port and rule_svr_status != svr_status:
                    post_data = json.dumps({ 'status': svr_status} )
                    print("       PUT " + waf_rest_url + "services/" + service + '/content-rules/' + rule + "/content-rule-servers/" + rule_svr_name + "/ " + post_data)
                    r = requests.put(waf_rest_url + "services/" + service + '/content-rules/' + rule + "/content-rule-servers/" + rule_svr_name, headers=hhh, data=post_data )
                    t = r.text
                    print("       -> " + json.loads(t)["msg"])
                    
            print("-----------------------------------end rule " + rule + "-------------------------------------")
    print("=================END SERVICE " + service + "==========================")
                
