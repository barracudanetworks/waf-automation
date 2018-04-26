# azureprofiles
Calls the manifests in the other modules. Refer to the manifests folder for details.

# Tree

.

├── cuda-azureprofiles -> cuda-azureprofiles

├── examples

│   └── init.pp

├── files

│   ├── azurevnetdeploy.template

│   ├── azurevnetparameters.template

│   ├── install_lamp.sh

│   ├── ubuntuparameters.json

│   ├── ubuntu.template

│   ├── wafparamspayg.template

│   └── wafpayg.template

├── Gemfile

├── manifests

│   ├── azure_rg.pp

│   ├── azure_storageaccount.pp

│   ├── init.pp

│   ├── lamp.pp

│   └── wafcreate.pp

├── metadata.json

├── Rakefile

├── README.md

└── spec

    ├── classes

    │   └── init_spec.rb

    └── spec_helper.rb
