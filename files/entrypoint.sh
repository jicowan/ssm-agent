#!/bin/bash

set -e
systemctl stop amazon-ssm-agent 
amazon-ssm-agent -register -code "<code>" -id "<id>" -region "<region>"
exec "$@"
