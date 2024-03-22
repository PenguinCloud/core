#!/bin/bash
ansible-playbook entrypoint.yml --tags=run -c local 
echo "Sleeping awaiting action!"
/bin/sleep infinity
