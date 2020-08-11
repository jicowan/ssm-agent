#!/bin/bash

set -e
systemctl stop amazon-ssm-agent 
amazon-ssm-agent -register -code "<ACTIVATION_CODE>" -id "<ACTIVATION_ID>" -region "REGION" -y
amazon-ssm-agent
