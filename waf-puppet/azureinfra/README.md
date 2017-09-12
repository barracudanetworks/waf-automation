# Introduction

Puppet is a configuration management software suite that helps to configure and manage remote systems in the network through a master/slave architecture through configuration files called manifests. Nodes to be managed are called agents and are connected to the master of masters through an SSL authentication mechanism. Each node sends "facts" to the master server which in turn prepares a catalog based on the facts and instructs the automation steps to the client. A scheduled job or a forced agent apply can be run to execute the instructions in the catalog. There is also a --noop flag that can be set to test the execution of the manifest. The facts are used to update the operational status of the managed node to the master server.

Since the process of launching the instance is in the public cloud, the managed node is used as a "WAF Management server" for administering the launch of the instances.

# Configuration Flow

1. Puppet Agent connects to Puppet master and sends facts
2. Puppet master compiles the information and sends a catalog file to the puppet agent.
3. Puppet agent now has the instructions to launch into Azure and provision Barracuda WAF instances.
4. Instances are provisioned with the initial configuration.

# This repo can be used as a Puppet Environment for :

1. Launching Barracuda WAF in Azure
2. Launcing a Ubuntu server with LAMP stack on Azure
3. Configuring the Barracuda WAF launched in step 1, with services and rule groups
4. Connect the Barracuda WAF to Barracuda Cloud Control
5. Setup a VRS scan to the web application being protected by the WAF

# Module Description**(all the modules can be seen in the modules directory in the environment)

1. azure : This module is the publicly available Puppet approved Azure module. Details : https://forge.puppet.com/puppetlabs/azure
2. azureprofiles : Created for dividing the puppet execution instructions into multiple files. This module provides the manifests for creating other azure resources.Please see details in the README for that module.
3. vrsinazure : Created for configuring a Barracuda VRS Scan to the configured service on the newly provisioned waf, https://campus.barracuda.com/product/vulnerabilityremediationservice/. Please got through the module's README for more details.
4. azurecudawafconfig : Configures the newly provisioned waf with services and rule groups. Also links the WAF to the Barracuda Cloud control https://campus.barracuda.com/product/cloudcontrol/. This linking is necessary to allow Barracuda VRS to be used to initiate a scan on any of the configured service.
5. azureroles : Created for dividing the puppet execution instructions into multiple files. This module calls the other module level manifests.


##### ALL OF THE SOURCE CODE ON THIS REPOSITORY IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL BARRACUDA BE LIABLE FOR ANY CLAIM, DAMAGES, OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOURCE CODE.#####
