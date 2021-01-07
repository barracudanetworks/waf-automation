# Set-Server-Maintenance-Mode

This is a utility script that sets a particular server to maintenance mode (or back in service) across all services on the WAF.  It is useful if you have multiple services with the same backend servers, and you want to take that server offline for maintenance.  This script replaces going into the UI and manually toggling each server's mode.

Here is how you would run it to put the server 192.168.1.9 in maintenance mode:

`.\Set_Server_Maintenance_Mode.ps1 -i 10.8.121.72 -u admin -p admin -s 192.168.1.9 -m "Out of Service Maintenance"`

Here is how you would re-enable the server:

`.\Set_Server_Maintenance_Mode.ps1 -i 10.8.121.72 -u admin -p admin -s 192.168.1.9 -m "In Service"`

(Replace the first IP with the WAF IP, and the username and password with your WAF credentials.)
