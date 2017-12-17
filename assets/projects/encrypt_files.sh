#!/bin/sh

AUTHORS="Foo-Manroot"
LAST_MODIF_DATE="2017-08-20"
VERSION="v1.0"

#####
# Script to encrypt all the files on the given directory recursively
#
# Requires:
#	gpg
#	openssl
#	shred
####


###
# Global variables
###
CRYPT_DIR="$PWD"	# Directory to be encrypted (or decrypted)
ERR_FILE="${CRYPT_DIR}/crypt_errors"

HELP_MSG="$AUTHORS
$LAST_MODIF_DATE
$VERSION
${PRETTY_RESET}
Script to encrypt or decrypt all the files on the given directory recursively.

Usage:

$0 [options] directory

Where 'options' may be one of the following:
	-d
	--decrypt
		Decrypts the directory, instead of encrypting it.
	-h
	--help
		Show this message and exits.
	-v
	--verbose
		Increases verbosity level.

And 'directory' is the directory to be encrypted/decrypted.
"

###
# Colours and formats to prettify the output
#
PRETTY_RESET=$(tput sgr0)

PRETTY_RED=$(tput setaf 9)
PRETTY_GREEN=$(tput setaf 10)
PRETTY_BLUE=$(tput setaf 14)

# ----

###
# Options
###
verbosity=0
decrypt=false
passphrase=""

####
# Parses options
####
parse_args ()
{
	SHORT_OPTS=dhv
	LONG_OPTS=decrypt,help,verbose

	# Checks that getopt can be used
	getopt --test > /dev/null
	if [ $? -ne 4 ]
	then
		log_error "$0: Error -> args can't be parsed, as 'getopt' can't be used."

		exit 1
	fi

	# Guarda el resultado para manejar correctamente los errores
	opts=$(getopt --options $SHORT_OPTS --longoptions $LONG_OPTS \
		--name "$0" -- "$@") || exit 1

	eval set -- "$opts"

	# Loop to evaluate the available options
	while true
	do
		case "$1" in
			-d | --decrypt)

				decrypt=true
				shift
				;;
			-h | --help)
				# Shows the help message and exits
				printf "%s" "$HELP_MSG"
				exit 0
				;;
			-v | --verbose )
				verbosity=$((verbosity + 1))
				shift
				;;
			--)
				# Ends the loop
				shift
				break
				;;
			*)
				log_error "$0: Unknown Error while parsing options - $1"
				exit 1
				;;
		esac
	done

	# Gets the positional arguments
	CRYPT_DIR="$(readlink -f "$*")"
	update_err_file

	if [ ! -d "$CRYPT_DIR" ]
	then
		log_error "Not a directory: '$CRYPT_DIR'."
		exit 1
	fi
}


###
# Functions to log, depending on the message level
#

log_info ()
{
	printf "%s\\n" "${PRETTY_BLUE}$*${PRETTY_RESET}"
}

log_error ()
{
	printf "%s\\n" "${PRETTY_RED}$*${PRETTY_RESET}"
}

log_success ()
{
	printf "%s\\n" "${PRETTY_GREEN}$*${PRETTY_RESET}"
}

###
# Other custom functions
#

update_err_file ()
{
	"$decrypt" && ERR_FILE="${CRYPT_DIR%/}/decrypt_errors"
	"$decrypt" || ERR_FILE="${CRYPT_DIR%/}/encrypt_errors"
}

get_passwd ()
{
	# Disables echo
	stty -echo

	# Trap to enable echo if the script is terminated
	trap 'stty echo' EXIT

	printf "Enter passphrase: "
	read -r passphrase

	# Repeats the passphrase to ensure the correctness of the passphrase
	printf "\\rRepeat passphrase: "
	read -r pass_check

	if [ -z "$passphrase" ] || [ -z "$pass_check" ]
	then
		printf "\\r"
		log_error "Error: the passphrase can't be empty"
		get_passwd
	fi

	if [ "$passphrase" != "$pass_check" ]
	then
		printf "\\r"
		log_error "Error: the passphrases doesn't match"
		get_passwd
	fi

	stty echo
	trap - EXIT

	printf "\\r                                                   \\r"
}


# === ENCRYPTION FUNCTIONS ====


encrypt_file ()
{
	file="$(readlink -f "$1")"

	# It seems that there are systems that doesn't accept file names larger than
	# 14 characters (at least, that's what `pathchk --portability` says...)
	out_file="$(tr -dc 'a-zA-Z0-9' < /dev/urandom | fold -w 10 | head -n 1).enc"

	if [ "$file" != "$ERR_FILE" ]
	then
		case "$file" in
			*.enc)
				test "$verbosity" -ge 2 && log_info "Skipped: '$file'"
				return
				;;
			*)
				if [ "$verbosity" -ge 1 ]
				then
					log_info "==> Encrypting '$file'"

					gpg --verbose \
						--passphrase "$passphrase" \
						--output "${file%/*}/$out_file" \
						--symmetric "$file"
					res=$?

					log_success " ----> DONE <---- "
				else
					gpg \
						--passphrase "$passphrase" \
						--output "${file%/*}/$out_file" \
						--symmetric "$file"
					res=$?
				fi

				if [ "$res" -eq 0 ]
				then
					if [ "$verbosity" -ge 2 ]
					then
						shred -vu "$file"
					else
						shred -u "$file"
					fi
				else
					printf "%s\\n" "$file" >> "$ERR_FILE"

					test "$verbosity" -ge 1 \
					&& log_error " ==> Couldn't encrypt file '$file'"
				fi
				;;
		esac
	fi
}

encrypt_dirname ()
{
	dir="$1"

	case "$dir" in
		*.enc)
			test "$verbosity" -ge 2 && log_info "Skipped: '$dir'"
			return
			;;
		*)
			test "$verbosity" -ge 1 \
				&& log_info "==> Encrypting '$(readlink -f "$dir")'"

			enc_name="$(printf "%s" "$(basename "$dir")" \
				| openssl enc \
					-aes-256-ctr \
					-nopad \
					-k "$passphrase" \
				| base32 \
				| tr -d "\\r\\n").enc"
			res=$?

			test "$verbosity" -ge 1 \
				&& log_success " ----> DONE <---- "

			if [ "$res" -eq 0 ]
			then
				dir="$(readlink -f "$dir")"

				mv "$dir" "${dir%/*}/$enc_name"

				if [ "$dir" = "$CRYPT_DIR" ]
				then
					CRYPT_DIR="${dir%/*}/$enc_name"
					update_err_file
				fi
			else
				printf "%s\\n" "$dir" >> "$ERR_FILE"

				test "$verbosity" -ge 1 \
				&& log_error " ==> Couldn't encrypt directory '$dir'"
			fi
			;;
	esac
}



# === DECRYPTION FUNCTIONS ====

decrypt_file ()
{
	file="$(readlink -f "$1")"

	if [ "$file" != "$ERR_FILE" ]
	then
		case "$file" in
			*.enc)
				# GPG generates the output file on the current
				# directory
				cd "${file%/*}" || return


				# There are errors if we pass --verbose in a variable,
				# so the two cases are separated
				if [ "$verbosity" -ge 1 ]
				then
					log_info "==> Decrypting '$file'"

					gpg --verbose \
						--passphrase "$passphrase" \
						--use-embedded-filename "$file"
					res=$?
					log_success " ----> DONE <---- "
				else
					gpg --quiet \
						--passphrase "$passphrase" \
						--use-embedded-filename "$file"
					res=$?
				fi

				if [ "$res" -eq 0 ]
				then
					if [ "$verbosity" -ge 2 ]
					then
						shred -uv "$file"
					else
						shred -u "$file"
					fi
				else
					printf "%s\\n" "$file" >> "$ERR_FILE"

					test "$verbosity" -ge 1 \
					&& log_error " ==> Couldn't decrypt file '$file'"
				fi
				;;
			*)
				test "$verbosity" -ge 2 && log_info "Skipped: '$file'"
				return
				;;
		esac
	fi
}

decrypt_dirname ()
{
	dir="$1"

	case "$dir" in
		*.enc)
			test "$verbosity" -ge 1 \
				&& log_info "==> Decrypting '$(readlink -f "$dir")'"

			# Gets the encrypted string
			string="${dir##*/}"
			string="${string%.enc}"

			dec_name="$(printf "%s" "$string" \
				| base32 -d \
				| openssl enc -d \
					-aes-256-ctr \
					-k "$passphrase")"
			res=$?

			test "$verbosity" -ge 1 \
				&& log_success " ----> DONE <---- "


			if [ "$res" -eq 0 ]
			then
				dir="$(readlink -f "$dir")"

				mv "$dir" "${dir%/*}/$dec_name"

				if [ "$dir" = "$CRYPT_DIR" ]
				then
					CRYPT_DIR="${dir%/*}/$dec_name"
					update_err_file
				fi
			else
				printf "%s\\n" "$dir" >> "$ERR_FILE"

				test "$verbosity" -ge 1 \
					&& log_error " ==> Couldn't decrypt directory '$dir'"
			fi
			;;

		*)
			test "$verbosity" -ge 2 && log_info "Skipped: '$dir'"
			return
			;;
	esac
}
# -----------------------------------

parse_args "$@"

if "$decrypt"
then
	test -z "$CRYPT_DIR" \
		&& log_error "Error: a directory to decrypt must be provided"
else
	test -z "$CRYPT_DIR" \
		&& log_error "Error: a directory to encrypt must be provided"
fi

get_passwd

# Encrypts (or decrypts) the files
if [ $verbosity -ge 1 ]
then
	printf "\\n"
	log_info " ---------------- "
	"$decrypt" && log_info " Decrypting files "
	"$decrypt" || log_info " Encrypting files "
	log_info " ---------------- "
	printf "\\n"
fi

find "$CRYPT_DIR" -type f \
	| while read -r file
	do
		"$decrypt" && decrypt_file "$file"
		"$decrypt" || encrypt_file "$file"
	done


# Encrypts (or decrypts) the name of the directories, starting from the deepest ones
if [ $verbosity -ge 1 ]
then
	printf "\\n"
	log_info " ---------------------- "
	"$decrypt" && log_info " Decrypting directories "
	"$decrypt" || log_info " Encrypting directories "
	log_info " ---------------------- "
	printf "\\n"
fi

find "$CRYPT_DIR" -type d \
	| sort -rn \
	| {
		while read -r dir
		do
			"$decrypt" && decrypt_dirname "$dir"
			"$decrypt" || encrypt_dirname "$dir"
		done

		# Shows the final report
		test -f "$ERR_FILE" \
			&& log_error "Program ended with $(
						wc -l "$ERR_FILE" | awk '{ print $1 }'
					) errors."
		"$decrypt" && log_info "New decrypted directory name: '$CRYPT_DIR'"
		"$decrypt" || log_info "New encrypted directory name: '$CRYPT_DIR'"
	}

log_success " ==> DONE <== "
