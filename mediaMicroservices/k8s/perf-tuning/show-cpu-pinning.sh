#! /usr/bin/python3

import os
import json
from subprocess import check_output

msg = check_output('sudo cat /var/lib/kubelet/cpu_manager_state'.split())
cpu_manager_stat = json.loads(msg.decode())


for _, v in cpu_manager_stat['entries'].items():
    for service, cpus in v.items():
        print(service, " : ", cpus)

