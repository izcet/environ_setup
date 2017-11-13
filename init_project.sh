#!/bin/sh

###############################################################################
## Functions ##################################################################

# I use a symlink to this script
# These commands are a convoluted way to find the location of the original
# So the original can call its necessary children script
SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"
SCRIPTPATH="$( readlink $SCRIPTPATH/$0)"
SCRIPTPATH="$( cd "$(dirname "$SCRIPTPATH")" ; pwd -P )"

GIT=.git # something something directory settings
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

echo "\033[0m\c" #clear the font styling

echo "${W}What is the name of the project?"
read NAME

# Basic error checking
if [ -z "$NAME" ] ; then
	error "The name of the project cannot be NULL."
	exit
fi
if [ -d $NAME ] ; then
	error "A directory called ${P}$NAME${R} already exists."
	exit
fi
if [ -f $NAME ] ; then
	error "A file named ${P}$NAME${R} already exists."
	exit
fi

# Git setup
echo "${B}Initializing git repository."
git init $NAME >> /dev/null

cd $NAME
echo "Entering repository."

# Remote stuff TODO make this with user-chosen remote names/urls
echo "${W}What is the ${C}vogsphere${W} repository url?"
read URL
while [ -z $URL ] ; do
	error "Directory or URL cannot be NULL"
	echo "${W}What is the ${C}vogsphere${W} repository url?"
	read URL
done
echo "${B}Adding remote ${C}origin${B} at ${P}$URL${B}"
git remote add origin $URL
if [ "$?" -eq 1 ] ; then
	error "Invalid repository. ${C}origin${R} will have to be manually set."
	git remote rm origin
	echo "${B}Remote ${C}origin${B} removed."
else
	git pull origin master 2> /dev/null
fi

echo "${W}(OPTIONAL) What is the ${C}github${W} repository url?"
echo "Press enter to skip..."
read URL
if [ ! -z $URL ] ; then
	echo "${B}Adding remote ${C}gh${B} at ${P}$URL${B}"
	git remote add gh $URL
	if [ "$?" -eq 1 ] ; then
		error "Invalid repository. ${C}gh${R} will have to be manually set."
		git remote rm gh
		echo "${B}Remote ${C}gh${B} removed."
	else
		git pull gh master 2> /dev/null	
	fi
else
	echo "\033[1A${B}Skipping..."
fi

if [ ! -z $GIT_DIR ] ; then
	GIT=$GIT_DIR
fi
echo "*.swp" >> $GIT/info/exclude
echo ".*.swp" >> $GIT/info/exclude

echo "${G}Creating ${P}author${G} file."
echo "$(whoami)" > author

# Project typing
echo "${W}What kind of project is ${P}$NAME${W} going to be?"
echo "${B}(For example: ${C}c$B, ${C}py$B, ${C}sh$B...)$N"
read TYPE

if [ -f $SCRIPTPATH/.init.$TYPE.sh ] ; then
	echo "${B}Starting a new ${C}$TYPE$B project...$N"
	sh $SCRIPTPATH/.init.$TYPE.sh
else
	echo "${R}No project type ${C}$TYPE$R found.$N"
fi

echo "${B}Adding files to git and making first commit.${W}"
git add .
git status
git commit -m "Initial commit"
echo "${G}Done.${N}"
