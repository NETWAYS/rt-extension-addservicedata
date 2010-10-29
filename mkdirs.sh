#!/bin/bash
DIR=$(dirname $(readlink -f $0))

CRDIRS="/bin /etc /html /po /sbin /var"

for I in $CRDIRS; do
	T=$DIR$I

	if [[ $1 == "--delete" ]] && [ -d $T ]; then
		rm -ri $T
		echo "Deleted .$I ... OK"
		continue
	fi

	echo -n "Creating .$I ... "

	if [ -d $T ]; then
		echo "ignore, exists already"
	else
		mkdir $T
		echo "OK"
	fi
done

