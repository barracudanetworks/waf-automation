# Powershell Module for Barracuda WAFs

# Introduction

In the modules folder beneath this README you will find modules or links to 3rd Party modules created for the Barracuda WAF solutions. 

This space will include details about how common DevOps practices/tools can be used with the Barracuda Web Applications Firewall product with primary focus on public cloud platforms like AWS and Microsoft Azure.

#Getting Started
1. Clone or Download the reposityory to your local PC
2. Copy each of the subfolders to the module folder into one of the Powershell Module directories on your PC. 

  * $env:USERPROFILE\Documents\WindowsPowerShell\Modules
  * C:\Program Files\WindowsPowerShell\Modules
  * C:\Windows\system32\WindowsPowerShell\v1.0\Modules

3. In your powershell session 
```powershell
Import-Module -Name BarracudaWaaS
```

```powershell
Import-Module -Name BarracudaVRS
```

#Examples
There are five examples here to get you started one that can be used to create a whitelist of IP's that can access a Application while blocking everything else and a second that demonstrates creating a new Application and running your first Vulnerability Scan

# REST API
##### REST API v2
https://api.waas.barracudanetworks.com/swagger/

# Vulnerability Remediation Service
## Powershell Module for connecting and triggering a new VRS Scan.




##### DISCLAIMER: ALL OF THE SOURCE CODE ON THIS REPOSITORY IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL BARRACUDA BE LIABLE FOR ANY CLAIM, DAMAGES, OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOURCE CODE. #####
