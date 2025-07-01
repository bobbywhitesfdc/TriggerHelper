#!/bin/bash
# Exit on error!
set -euxo pipefail
if [ $# -lt 1 ]
then
	echo TARGET alias is required
	exit 1
fi

TARGET=$1
#Nebula: 04t5Y0000027L98QAE
sf package install -o $TARGET --package 04t5Y0000027L98QAE -w20
