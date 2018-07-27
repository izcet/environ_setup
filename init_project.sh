#!/bin/bash

###############################################################################
# Variables

# I sometimes use an alias or symlink to this script
# These commands are a convoluted way to find the location of the original
# So the original can call its necessary children script

THIS_FILE_DIR="`dirname \"$0\"`"
SCRIPTPATH="`cd \"$THIS_FILE_DIR\" ; pwd -P `"

# This should do the appropriate actions if this is symlinked
# FIXME: Be warned that this is STILL UNTESTED
if [ -L "$THIS_FILE_DIR" ] ; then
    SCRIPTPATH="`readlink \"$SCRIPTPATH/$0\"`"
    SCRIPTPATH="`cd \"\`dirname \\\"$SCRIPTPATH\\\"\`\" ; pwd -P `"
fi

GIT=.git

R='[31m' # Red
Y='[33m' # Yellow
G='[32m' # Green
C='[36m' # Cyan
B='[34m' # Blue
P='[35m' # Purple
W='[37m' # White
N='[0m'  # No Color


###############################################################################
# Functions

# Output a red error message
# usage: error <text>
error () {
    echo -e "${R}Error: $1${N}"
}

# Create a directory. somewhat redundant
# usage: make_dir <directory>
make_dir () {
    if [ -z "$1" ] ; then
        error "NULL parameter passed to ${P}make_dir()" # what is this, C?
        return 1
    fi
    echo -e "${G}Creating directory ${P}$1"
    mkdir -p "$1"
}


###############################################################################
# Code

echo -e "${N}${W}What is the name of the project?"
read NAME

# Basic error checking
if [ -z "$NAME" ] ; then
    error "The name of the project cannot be NULL."
    exit

elif [ -d "$NAME" ] ; then
    error "A directory named ${P}$NAME${R} already exists."
    exit

elif [ -f "$NAME" ] ; then
    error "A file named ${P}$NAME${R} already exists."
    exit
fi

# Git setup
echo -e "${B}Initializing git repository."
git init "$NAME" >> /dev/null

echo -e "Entering repository."
cd "$NAME"

# Remote stuff
echo -e "${B}Optional: Add remote repository information.$N"

REMOTE="origin"
while [ -n "$REMOTE" ] ; do
    
    echo -e "${W}What is the ${P}remote name$W?"
    echo -e "$B(Enter a duplicate remote name to delete)$N"
    echo -e "${B}(Press enter to skip...)$N"
    
    read REMOTE
    if [ -n "$REMOTE" ] ; then
        
        echo -e "${W}What is the ${P}remote URL$W?"
        
        read URL
        if [ -n "$URL" ] ; then
            
            git remote rm "$REMOTE" &> /dev/null
            echo -e "${B}Adding remote ${C}$REMOTE${B} at ${P}$URL${B}"
            git remote add "$REMOTE" "$URL"
            if [ "$?" -eq 1 ] ; then
                error "Invalid repository. Deleting remote $C$REMOTE$R."
                git remote rm "$REMOTE"
            else
                git pull "$REMOTE" master &> /dev/null
            fi
        
        else
            echo -e "${R}No remote added for ${P}$REMOTE$R.$N"
        fi
    fi
done

if [ -n "$GIT_DIR" ] ; then
    GIT="$GIT_DIR"
fi

# Project typing
echo -e "${W}What kind of project is ${P}$NAME${W} going to be?"
echo -e "${B}(For example: ${C}c$B, ${C}py$B, ${C}sh$B...)$N"
read TYPE

if [ -n "$TYPE" ] ; then
    
    if [ -f "$SCRIPTPATH/.init.$TYPE.sh" ] ; then
        echo -e "${B}Starting a new ${C}$TYPE$B project...$N"
        sh "$SCRIPTPATH/.init.$TYPE.sh" "$NAME" "$GIT"
    else
        echo -e "${R}No project type ${C}$TYPE$R found.$N"
    fi

else
    echo -e "${B}Skipping...$N"
fi

echo -e "${B}Adding files to git and making first commit.${W}"
git add .
git status
git commit -m "Initial commit"
echo -e "${G}Done.${N}"

