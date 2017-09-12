# Ansible Playbook samples

waf_config_sample.yml: Sample ansible playbook that can be used to create a service on a Barracuda Web Application Firewall using the built in URI module.
The module calls the Barracuda REST APIv1 for logging in with a restapi token, and then creates a service.
[RESTAPI documentation can be found here](https://campus.barracuda.com/product/webapplicationfirewall/article/WAF/RESTAPI/)

waf_ec2.yml: Creates a Barracuda WAF EC2 instance on AWS

azure_vm_create.yaml: Creates a Barracuda WAF VM, a storage account, NIC interface and a NSG on Microsoft Azure in a resource group.

##### DISCLAIMER: ALL OF THE SOURCE CODE ON THIS REPOSITORY IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL BARRACUDA BE LIABLE FOR ANY CLAIM, DAMAGES, OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOURCE CODE. #####
 

