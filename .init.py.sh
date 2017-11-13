#!/bin/sh
###############################################################################
## Variables ##################################################################

NAME=$1 # name of the project, because apparently variables aren't copied
GIT=$2

R='\033[31m' # Red
Y='\033[33m' # Yellow
G='\033[32m' # Green
C='\033[36m' # Cyan
B='\033[34m' # Blue
P='\033[35m' # Purple
W='\033[37m' # White
N='\033[0m'	 # No Color

###############################################################################
## Functions ##################################################################

# Output a red error message
# usage: error <text>
error () {
	echo "${R}Error: $1${N}"
}

# Create a directory. somewhat redundant
# usage: make_dir <directory>
make_dir () {
	if [ -z $1 ] ; then
		error "NULL parameter passed to ${P}make_dir()" # what is this, C?
		return 1
	fi
	echo "${G}Creating directory ${P}$1"
	mkdir -p $1
}

###############################################################################
## Code #######################################################################

