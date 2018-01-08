# Set-Server-Maintenance-Mode

This is a utility script that sets a particular server to maintenance mode (or back in service) across all services on the WAF.  It is useful if you have multiple services with the same backend servers, and you want to take that server offline for maintenance.  This script replaces going into the UI and manually toggling each server's mode.

How to run the script: 

`perl bulkedit_server.pl <WAF IP> <WAF port> <REST login username> <password> <Server IP> <Server Port> <Status>`

Where status can be any of:

1. In Service 
2. Out of Service Maintenance 
3. Out of Service Sticky 
4. Out of Service All 

For example:

`perl /tmp/change_server_status.pl 1.1.1.1 8000 admin password 2.2.2.2 80 "In Service"`
