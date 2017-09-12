#!/bin/bash

#.NET Core Install
sudo sh -c 'echo "deb [arch=amd64] https://apt-mo.trafficmanager.net/repos/dotnet-release/ xenial main" > /etc/apt/sources.list.d/dotnetdev.list'
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 417A0893
sudo apt-get update

sudo apt-get install dotnet-dev-1.0.0-preview2.1-003177 -y


#PowerShell Core 6.14
wget https://github.com/PowerShell/PowerShell/releases/download/v6.0.0-alpha.14/powershell_6.0.0-alpha.14-1ubuntu1.16.04.1_amd64.deb
sudo dpkg -i powershell_6.0.0-alpha.14-1ubuntu1.16.04.1_amd64.deb
sudo apt-get install -f -y

#Azure RM NetCore Preview Module Install
powershell Install-Module -Force AzureRM.NetCore.Preview
powershell Import-Module AzureRM.NetCore.Preview
if [[ $? -eq 0 ]]
    then
        echo "Successfully installed PowerShell Core with AzureRM NetCore Preview Module."
    else
        echo "PowerShell Core with AzureRM NetCore Preview Module did not install successfully." >&2
fi

#Install Azure CLI
#Address https://azure.microsoft.com/en-us/documentation/articles/xplat-cli-install/

    sudo apt-get install node.js npm -y
    sudo npm install -g azure-cli
    sudo ln -s /usr/bin/nodejs /usr/bin/node

#Install azure gems
sudo /opt/puppetlabs/puppet/bin/gem install retries --no-ri --no-rdoc
sudo /opt/puppetlabs/puppet/bin/gem install azure --version='~>0.7.0' --no-ri --no-rdoc
sudo /opt/puppetlabs/puppet/bin/gem install azure_mgmt_compute --version='~>0.3.0' --no-ri --no-rdoc
sudo /opt/puppetlabs/puppet/bin/gem install azure_mgmt_storage --version='~>0.3.0' --no-ri --no-rdoc
sudo /opt/puppetlabs/puppet/bin/gem install azure_mgmt_resources --version='~>0.3.0' --no-ri --no-rdoc
sudo /opt/puppetlabs/puppet/bin/gem install azure_mgmt_network --version='~>0.3.0' --no-ri --no-rdoc
sudo /opt/puppetlabs/puppet/bin/gem install hocon --version='~>1.1.2' --no-ri --no-rdoc
#Other Necessary Packages
sudo apt-get install -y vim
azure config mode asm
sudo apt-get install -y git
sudo apt-get install -y gem
sudo apt-get install -y ruby
git clone https://github.com/pendrica/azure-credentials.git


