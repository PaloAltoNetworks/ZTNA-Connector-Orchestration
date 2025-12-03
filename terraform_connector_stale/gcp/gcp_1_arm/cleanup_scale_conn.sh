#!/usr/bin/env bash
for d in */ ; do
    cd "$d"
    terraform init
    terraform destroy --auto-approve
    cd .. 
done
rm -rf tf_ztna-dp-subnet-scale-conn-*
