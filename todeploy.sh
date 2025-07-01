#!/bin/bash
# Exit on error!
set -euxo pipefail
if [ $# -lt 1 ]
then
	echo Filename is required
	exit 1
fi

TARGET=TRIGGER
SOURCEFILE=$1
echo $SOURCEFILE

if [ -f $SOURCEFILE ]; then
    echo Deploying $SOURCEFILE to $TARGET
else
    echo Source file name invalid $SOURCEFILE
	exit 1
fi



while IFS="" read -r p || [ -n "$p" ]
do
  [[ "$p" =~ ^#.*$ ]] && continue
  sf project deploy start -o $TARGET --ignore-conflicts -d $p
done < $SOURCEFILE
