#!/bin/bash

set -e
systemctl stop amazon-ssm-agent 
amazon-ssm-agent -register -code <yourcode> -id <yourid> -region <awsregion> -y
amazon-ssm-agent
