# Introduction

This vagrantfile has the bootstrapping script to initialize a Ubuntu system with AWS software. 

# Getting started

1. `vagrant up`
2. `vagrant ssh`
3. edit the `/etc/puppetlabs/puppet/puppet.conf` file with the following entries:
`server = <puppetmaster>`
`environment = <aws environment name>`
4. curl -k https://<puppetserver fqdn>:8140/packages/current/install.bash | sudo bash
5. puppet agent -t

At this stage the puppet server should sign this request.

6. puppet agent -t --> needed again to execute the puppet run

##### DISCLAIMER: ALL OF THE SOURCE CODE ON THIS REPOSITORY IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL BARRACUDA BE LIABLE FOR ANY CLAIM, DAMAGES, OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOURCE CODE. #####

