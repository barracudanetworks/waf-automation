### Introduction

Ansible is a configuration automation software. Its popular in the devops community for being a light weight software and does not need agents on the target system. The Ansible master connects to the target machine through SSH. 

### Usage Requirements

To use the code samples, install Ansible on the local system and configure the host inventory file. The sample host inventory file:

```
[targets]

<hostname>	ansible_connection=local

```

### Playbooks

Playbooks in Ansible are used to write a set of instructions that are given to a client. Playbook files are created with yaml filetype and need to adhere to the whitespace syntax

To run a particular playbook: `ansible-playbook <playbook-file.yml>`

### Playbook Samples
1. Configuring a HTTP Service: waf_svc_http_config.yaml
2. Configuring a HTTPS Service: waf_svc_https_config.yaml



