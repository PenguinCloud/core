#!/bin/bash
ansible-playbook upstart.yml --tags=exec -c local 
echo "Sleeping awaiting action!"
/bin/sleep infinity
