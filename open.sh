#!/bin/bash
# Exit on error!
set -euxo pipefail

function prop {
    grep "${1}" project.properties|cut -d'=' -f2
}

sf org open -o "$(prop 'default.env.alias' )"


