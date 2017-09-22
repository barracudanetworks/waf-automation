# Using Puppet to deploy and manage the Barracuda Web Application Firewall

### How Puppet works

"Puppet technology helps you know what's in your infrastructure, and how it's configured across all the physical components of your data center; your virtualized and cloud infrastructure; and everything you're running in containers. Puppet automatically keeps everything in its desired state, enforcing consistency and keeping you compliant, while giving you complete control to make changes as your business needs evolve." -- Courtesy: [Puppet](https://puppet.com/products)

### What's here?

You can find Puppet environments for deploying and configuring Baracuda Web Application Firewalls in [AWS](https://github.com/barracudanetworks/waf-automation/tree/master/waf-puppet/aws) and [Azure](https://github.com/barracudanetworks/waf-automation/tree/master/waf-puppet/azureinfra)
### Important Note
The code samples presented in this repo use Linux commands specific to Ubuntu platforms. If the platform on which you are running this code is different, please make necessary changes.

### Steps
### **On the Master**
1. Move the directory (aws or azureinfra, depending on the required environment) to your Puppet master. Path on latest version of Puppet Enterprise: /etc/puppetlabs/code/environments/ 
2. Install the pre-requisite module, for example, for using the AWS environment, install the Puppet module for AWS. Refer to the README for each environment for more details on fulfulling the requirements.
3. Change the user values as needed to launch the instances with specific tags, in your preferred region / account etc.
4. Execute `puppet agent -t` on Puppet Master. This is needed to ensure the new environment is committed to the master system.

### **On the Agent**
1. Install the puppet agent software. On the latest Puppet Enterprise installation, this can be done using: `curl -k https://<PE master>:8140/packages/current/install.bash|sudo bash`. Refer to the Puppetlabs documentation for more details.

2. Configure the puppet.conf file (`/etc/puppetlabs/puppet/puppet.conf`) and set the following entries:

`server = <PE master FQDN>`

`environment = <environment name>`

3. Create a directory under /etc/puppetlabs/code/environments/ with the name as the environment name. For example, for using the aws environment, the directory should be aws (as per the directory name in this repo)

4. Create the credentials file. For AWS, the credentials file will be in .aws and for Azure the HOCON format file should be placed under `/etc/puppetlabs/puppet/`. Refer to the AWS or Azure modules for more information on the credentials file and the creation of it.

5. Create the JSON files for the WAF credentials under `/etc/puppetlabs/puppet/`

6. Execute `puppet agent -t`

##### DISCLAIMER: ALL OF THE SOURCE CODE ON THIS REPOSITORY IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL BARRACUDA BE LIABLE FOR ANY CLAIM, DAMAGES, OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOURCE CODE. ##### 
