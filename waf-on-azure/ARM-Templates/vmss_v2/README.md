<img src ="https://www.barracuda.com/assets/img/layout/logo/logo.svg" width="200"/>

# Deploying the Barracuda Web Application Firewall VM Scale Set(PAYG) in Azure

## Introduction

This solution uses an Microsoft ARM template to launch the deployment of Barracuda WAF(PAYG) VM Scale Set. This templates creates and configures a new Azure load balancer in the resource group. Traffic flows from the Azure load balancer to the Barracuda WAF cluster and then to the backend application servers. The Barracuda WAF are configured in single-NIC and single-IP mode. As traffic increases or decreases, the number of Barracuda WAF instances automatically increases or decreases accordingly. Scaling rules are currently based on *CPU percentage*, *network out* and *network in* throughput.

**Networking Stack Type:** This solution gives an option to deploy WAF in existing VNET or create a new VNET.

## Prerequisites and configuration notes
   - This template requires service principal(for peer discovery it uses Azure API).
   - Azure Storage account having Barracuda WAF backup file if you need to do backup based boostrapping.
   - Only HTTP service type creation is supported with basic bootstrapping. Backend application servers needs to be specified in IP:PORT or HOSTNAME:PORT format.Multiple servers can be configured in csv format(e.g. `www.example.com:80,10.0.0.9:80`)
   - Ensure that you add appropriate firewall rules in the network security group(NSG) based on your services. The default open ports are 443, 8443, 8000.

## Deployment Architecture <a name="config">

The following is an sample deployment architecture for Barracuda WAF VMSS. All access to the Barracuda WAF instances is through an Azure Load Balancer. The Azure Load Balancer processes both management and data plane traffic.

Refer to Azure LB NAT rules to find out MGMT access Ports. MGMT access are generally available over `azure_lb_ip:8000, azure_lb_ip:8001` and so on.

![Deployment Architecture](images/WAF_deployement.png)


## Installation

### <a name="azure"></a>Azure deploy button

   - **PAYG**: Deploy Barracuda WAF with pay-as-you-go hourly billing. <br><a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Frahulgupta-jsr%2FTemplates%2Fmaster%2Fvmss_v2%2FmainTemplate.json">
       <img src="http://azuredeploy.net/deploybutton.png"/></a><br><br>

## More Information
   - Please visit our campus for more information about the Barracuda WAF VMSS support.
   - [Deploying Barracuda WAF in Azure](https://campus.barracuda.com/product/webapplicationfirewall/article/WAF/DeployWAFInAzure/)

## Note
   BYOL based Barracuda WAF VMSS is not yet supported. This will be made available soon.

##### DISCLAIMER: ALL OF THE SOURCE CODE ON THIS REPOSITORY IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL BARRACUDA BE LIABLE FOR ANY CLAIM, DAMAGES, OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOURCE CODE. #####
