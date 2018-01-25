#!/bin/bash
#To deselect an imported resource
#After running init.sh,check the lineage in the file terraform.tfstate and copy the same lineage into the file terraformrefresh.tfstate
#run the command 'source refresh.sh' before executing the file
alias refresh='cp terraformrefresh.tfstate terraform.tfstate'
