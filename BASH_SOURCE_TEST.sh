#!/bin/bash

# permissions
if [ "$(whoami)" != "root" ]; then
	echo "Root privileges are required to run this, try running with sudo..."
	exit 2
fi
pwd
current_directory="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
pwd
$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
echo $current_directory
echo ${BASH_SOURCE[0]}
echo "$( dirname "${BASH_SOURCE[0]}" )"
cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd
$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
$(/home/panicjens/ANSIBLE-PLAYS/bash-scripts)