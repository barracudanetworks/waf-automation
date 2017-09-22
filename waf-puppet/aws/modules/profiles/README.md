# profiles

Calls all the manifests in other modules. Refer to the manifests folder for details.

# Tree

├── cudawafaws-profiles -> cudawafaws-profiles
├── examples
│   └── init.pp
├── Gemfile
├── manifests
│   ├── base.pp
│   ├── ec2create.pp
│   ├── elbcreate.pp
│   ├── hieradata
│   │   └── common.yaml
│   ├── hiera.yaml
│   ├── init.pp
│   ├── serversecgroup.pp
│   └── wafsecgroup.pp
├── metadata.json
├── Rakefile
├── README.md
├── spec
│   ├── classes
│   │   └── init_spec.rb
│   └── spec_helper.rb
└── templates
    └── lamp.sh.erb
