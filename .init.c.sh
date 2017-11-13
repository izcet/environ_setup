#!/bin/sh

NAME=$1
GIT=$2

LIB=libft
LDIR=~/backups/projects

INC=inc
SRC=src
MAK=Makefile

# File containing vim commands to be run on each file
VIM=.vim_commands
# The commands in said file
COM=":Stdheader\ndd\n:wq"

make_with_vim () {
	if [ -z $1 ] ; then
		error "NULL parameter passed to ${P}make_with_vim()"
		return 1
	fi
	echo "${G}Creating file ${P}$1"
	vim -s $VIM $1
}

# Append a line of text to the end of the Makefile
# usage: add_line <text>
add_line () {
	echo "$1" >> $MAK
}

# Insert a line of text at a specific line number
# WARNING: may be off-by-one. check before use
# usage: insert_at <text> <line number>
insert_at () {
	head -n $2 $MAK > .temp$MAK
	echo "$1\c" >> .temp$MAK
	tail -n +$2 $MAK >> .temp$MAK
	mv .temp$MAK $MAK
}

# Add the necessary blocks of code to a C Makefile to include a library
# Initially uses default values later in this code
# WARNING: But those values have to be set before each new call
# usage: add_lib 
add_lib () {
	if [ ! -d $LDIR/$LIB ] ; then
		error "No directory found at ${P}$LDIR/$LIB$R"
		return 1
	fi
	if [ -d ./$LIB ] ; then
		error "Library $P$LIB$R already exists in this directory."
		return 1
	fi
	make_dir ./$LIB
	echo "${B}Copying files from library ${P}$LDIR/$LIB"
	ls -1A $LDIR/$LIB/ | grep -v .git | xargs -I % cp -rf $LDIR/$LIB/% ./$LIB/
	echo "${B}Adding necessary lines to ${P}$MAK"
	NLIB=$(echo $LIB | awk '{print toupper($0)}')
	add_line "\n\$($NLIB):"
	add_line "\t@\$(MAKE) -C \$(${NLIB}_DIR)"
	insert_at "" 27
	insert_at "$NLIB\t\t=\t\$(${NLIB}_DIR)/\$(${NLIB}_LIB)" 27
	insert_at "${NLIB}_INC\\t=\\t#includes directory, if applicable" 27
	insert_at "${NLIB}_LIB\t=\t$LIB.a #assuming project is named the same" 27
	insert_at "${NLIB}_DIR\t=\t$LIB" 27
	sed -i '' -e "s|I $INC|I \$(${NLIB}_DIR)/\\\$(${NLIB}_INC) -I $INC|" $MAK
	sed -i '' "s/^.PHONY: /.PHONY: $LIB /" $MAK
	sed -i '' "s/^all: /all: \$($NLIB) /" $MAK
	# This nonsense here. sed requires an escaped literal newline and tab
	sed -i '' "s/^clean:/clean:\\
	@cd \$(${NLIB}_DIR) \&\& make clean/" $MAK
	sed -i '' "s/^fclean: clean/fclean: clean\\
	@cd \$(${NLIB}_DIR) \&\& make fclean/" $MAK
	sed -i '' "s/\$(CC) \$(FLAGS)/\$(CC) \$(FLAGS) \$(${NLIB})/" $MAK
}

## Code #######################################################################

echo "*.[oa]" >> $GIT/info/exclude

echo "$COM" >> $VIM

make_dir $SRC
make_dir $INC

make_with_vim $INC/$NAME.h
echo "${B}Protecting against double inclusion."
echo "#ifndef $(echo $NAME | awk '{print toupper($0)}')_H" >> $INC/$NAME.h
echo "# define $(echo $NAME | awk '{print toupper($0)}')_H" >> $INC/$NAME.h
echo "\n\n\n#endif" >> $INC/$NAME.h

make_with_vim $MAK
echo "${B}Prepopulating text in ${P}$MAK"
add_line "NAME\t\t=\t$NAME\n"
add_line "CC\t\t\t=\tclang"
add_line "CFLAGS\t\t=\t-Wall -Werror -Wextra"
add_line "XFLAGS\t\t=\t#-flags -for -X"
add_line "FLAGS\t\t=\t\$(CFLAGS) \$(XFLAGS)\n"
add_line "SRC_DIR\t\t=\t$SRC"
add_line "SRC_FILE\t=\t##!!##"
add_line "SRCS\t\t=\t\$(addprefix \$(SRC_DIR)/, \$(SRC_FILE))\n"
add_line "OBJ_DIR\t\t=\tobj"
add_line "OBJ_FILE\t=\t\$(SRC_FILE:.c=.o)"
add_line "OBJS\t\t=\t\$(addprefix \$(OBJ_DIR)/, \$(OBJ_FILE))\n"
add_line "INC_DIR\t\t=\t-I $INC\n" # append text to specific lines
add_line ".PHONY: all clean fclean re\n" #libft
add_line "all: \$(NAME)\n"
add_line "\$(NAME): \$(SRCS) | \$(OBJS)"
add_line "\t\$(CC) \$(FLAGS) \$(OBJS) \$(INC_DIR) -o \$(NAME) #WARNING: will not compile on linux unless the library is at the end of the line\n"
add_line "\$(OBJ_DIR)/%.o: \$(SRC_DIR)/%.c | \$(OBJ_DIR)"
add_line "\t@\$(CC) -c \$^ \$(CFLAGS) \$(INC_DIR) -o \$@\n"
add_line "clean:"
add_line "\t@rm -rf \$(OBJ_DIR)\n"
add_line "fclean: clean"
add_line "\t@rm -f \$(NAME)\n"
add_line "re: fclean all\n"
add_line "\$(OBJ_DIR):"
add_line "\t@mkdir -p \$(OBJ_DIR)"

echo "${W}Would you like to include $P$LIB$W from $P$LDIR$W ?"
echo "\t${C}[1]$W yes"
echo "\t${C}[2]$W no"
read TYPE
if [ "$TYPE" -eq "1" ] ; then
	add_lib
elif [ "$TYPE" -ne "2" ] ; then
	error "${C}$TYPE${R} is not a valid response."
fi

echo "${W}Would you like to include another library?"
echo "\t${C}[1]$W yes"
echo "\t${C}[2]$W no"
read TYPE
while [ "$TYPE" -eq "1" ] ; do
	echo "${W}Enter library directory name:"
	read LIB
	echo "Enter path to library: (full path to library)"
	read LDIR
	add_lib
	echo "${W}Would you like to include another library?"
	echo "\t${C}[1]$W yes"
	echo "\t${C}[2]$W no"
	read TYPE
done
if [ "$TYPE" -ne "2" ] ; then
	error "${C}$TYPE${R} is not a valid response."
fi
rm $VIM
