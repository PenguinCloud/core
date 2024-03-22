#!/bin/bash
ansible-playbook entrypoint.yml --tags=exec -c local 
echo "Sleeping awaiting action!"
/bin/sleep infinity
