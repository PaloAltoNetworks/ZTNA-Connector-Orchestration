#!/usr/bin/env bash
for d in */ ; do
    cd "$d"
    terraform init
    terraform destroy --auto-approve
    cd .. 
done
rm -rf tf_conn-appscale-*
