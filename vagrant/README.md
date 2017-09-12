# Introduction

In a nutshell, Vagrant is a tool for working with virtual environments, and in most circumstances, this means working with virtual machines. Vagrant provides a simple and easy to use command-line client for managing these environments, and an interpreter for the text-based definitions of what each environment looks like, called Vagrantfiles. Vagrant is open source, which means that anyone can download it, modify it, and share it freely.

# Why Vagrant?

Most of the devops tools we use commonly need different dependent software to be installed. We also need to install work flow specific software. It helps to have a Vagrant box that can boot up with all these software installed during bootup aka bootstrapping. We provide access to vagrantfiles that will have bootstrapping code.

# Content
1. [AWS](https://github.com/barracudanetworks/waf-automation/tree/master/vagrant/AWS)
2. [Azure](https://github.com/barracudanetworks/waf-automation/tree/master/vagrant/Azure)
3. [Foreman](https://github.com/barracudanetworks/waf-automation/tree/master/vagrant/Foreman)

# How-to

1. Install [Vagrant](https://www.vagrantup.com/docs/installation/)
2. Create a directory for your environment (eg. AWS or Azure) within the Vagrant installation path
3. Place the relevant vagrantfile from this repo, into the directory. (You can avoid this step if the directory is copied from this space instead of creating a new directory as mentioned in step 2)
4. Execute `vagrant up`
5. To SSH into the machine `vagrant ssh`
6. To stop the machine `vagrant halt`
 

##### DISCLAIMER: ALL OF THE SOURCE CODE ON THIS REPOSITORY IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL BARRACUDA BE LIABLE FOR ANY CLAIM, DAMAGES, OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOURCE CODE. #####

