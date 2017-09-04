#!/bin/sh

AUTHOR="Miguel García Martín"
DATE="2017-08-06"

PRETTY_RESET=$(tput sgr0)

PRETTY_RED=$(tput setaf 9)
PRETTY_GREEN=$(tput setaf 10)
PRETTY_YELLOW=$(tput setaf 11)
PRETTY_BLUE=$(tput setaf 14)


###
# Cleans the directory name of any trailing slashes
###
clean_dirname ()
{
	DIR="$1"

	case $DIR in
		*[!/]*/)
			DIR="${DIR%${DIR##*[!/]}}"
		;;
	esac

	echo "$DIR"
}


LANGS="es"


HELP_MSG="
${PRETTY_YELLOW}$(basename "$0") - $AUTHOR - $DATE ${PRETTY_RESET}

	Script to create all the files needed to create a post on every supported
language. Currently, those languages are: en $LANGS
${PRETTY_BLUE}
Usage:
	$(basename "$0") <post_ref> [-h | --help]
${PRETTY_RESET}
	The argument 'post_ref' is the value of the attribute 'ref' on the created posts
"

if [ $# -ne 1 ]
then
	printf "${PRETTY_RED}Error: incorrect number of arguments${PRETTY_RESET}\n"

	printf "$HELP_MSG"
	exit 1
fi


if [ $# -eq 1 ]
then
	if [ "$1" = "-h" ] || [ "$1" = "--help" ]
	then
		printf "$HELP_MSG"
		exit 0
	else
		REF="$1"
	fi
fi

DATE="$(date +%Y-%m-%d)"
DATE_EXT="$DATE $(date +%H:%M:%S)"
TIME_ZONE="$(date +%z)"

FILENAME="$DATE-$REF.markdown"

# The post's title is the ref split into words and capitalized
POST_TITLE="$(IFS=- ; set -f ; for a in $REF ; do printf "$a " ; done )"
POST_TITLE="$(printf "%s" "$POST_TITLE" | sed -e "s/\b\(.*\)/\u\1/")"


HEADER="---
layout: post
title:  \"$POST_TITLE\"
date:	$DATE_EXT $TIME_ZONE
author: foo
categories:
ref: $REF
---
"

# Checks that there are not any other articles with the same ref
res="$(find . -name "*.markdown" -exec grep -i "ref: $REF" "{}" \; | wc -l)"

if [ "$res" -ne 0 ]
then
	printf "${PRETTY_RED}%s${PRETTY_RESET}\n"\
		"There are already $res other articles with the ref '$REF'"
	exit 1
fi


# Creates the files with the headers

printf "${PRETTY_BLUE}%s${PRETTY_YELLOW}\n%s${PRETTY_RESET}\n" \
	"Creating post files with the following header: " \
	"$HEADER"


printf "${PRETTY_BLUE}%s${PRETTY_RESET}\n" \
	"Adding post '$FILENAME'..."
echo "$HEADER" >> "$FILENAME"


for lang in $LANGS
do

	# Modifies the header according to the current language
	HEADER="$(cat <<- EOF
	---
	layout: post
	title:  "$POST_TITLE"
	date:	$DATE_EXT $TIME_ZONE
	author: foo
	categories: $lang
	lang: $lang
	ref: $REF
	---
	EOF
	)"

	if [ ! -d "$lang" ]
	then
		printf "${PRETTY_YELLOW}%s${PRETTY_RESET}\n" \
			"Creating directory '$lang'..."
		mkdir "$lang"

		printf "${PRETTY_GREEN}Done${PRETTY_RESET}\n"
	fi

	printf "${PRETTY_BLUE}%s${PRETTY_RESET}\n" \
		"Adding post '$lang/$FILENAME'..."

	echo "$HEADER" >> "$lang/$FILENAME"
done


printf "${PRETTY_GREEN} ---- Done ---- ${PRETTY_RESET}\n"

