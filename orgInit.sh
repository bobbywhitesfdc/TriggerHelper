#!/bin/bash
# Exit on error!
set -euxo pipefail

function prop {
    grep "${1}" project.properties|cut -d'=' -f2
}
#create scratch org
# let it auto-assign the username ( username="$(prop 'user.admin' )" )
sf org create scratch -f config/project-scratch-def.json -a "$(prop 'default.env.alias' )"  --set-default --duration-days 28 -v CSGPSDEVOPS
