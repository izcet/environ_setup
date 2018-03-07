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

# Remote stuff
echo "${B}Optional: Add remote repository information.$N"
REMOTE="origin"
while [ ! -z $REMOTE ] ; do
	echo "${W}What is the ${P}remote name$W?"
	echo "$B(Enter a duplicate remote name to delete)$N"
	echo "${B}(Press enter to skip...)$N"
	read REMOTE
	if [ ! -z $REMOTE ] ; then
		echo "${W}What is the ${P}remote URL$W?"
		read URL
		if [ ! -z $URL ] ; then
			git remote rm $REMOTE &> /dev/null
			echo "${B}Adding remote ${C}$REMOTE${B} at ${P}$URL${B}"
			git remote add $REMOTE $URL
			if [ "$?" -eq 1 ] ; then
				error "Invalid repository. Deleting remote $C$REMOTE$R."
				git remote rm $REMOTE
			else
				git pull $REMOTE master &> /dev/null
			fi
		else
			echo "${R}No remote added for ${P}$REMOTE$R.$N"
		fi
	fi
done

if [ ! -z $GIT_DIR ] ; then
	GIT=$GIT_DIR
fi
echo "*.swp" >> $GIT/info/exclude
echo ".*.swp" >> $GIT/info/exclude

# Project typing
echo "${W}What kind of project is ${P}$NAME${W} going to be?"
echo "${B}(For example: ${C}c$B, ${C}py$B, ${C}sh$B...)$N"
read TYPE

if [ ! -z $TYPE ] ; then
	if [ -f $SCRIPTPATH/.init.$TYPE.sh ] ; then
		echo "${B}Starting a new ${C}$TYPE$B project...$N"
		sh $SCRIPTPATH/.init.$TYPE.sh "$NAME" "$GIT"
	else
		echo "${R}No project type ${C}$TYPE$R found.$N"
	fi
else
	echo "${B}Skipping...$N"
fi

echo "${B}Adding files to git and making first commit.${W}"
git add .
git status
git commit -m "Initial commit"
echo "${G}Done.${N}"
