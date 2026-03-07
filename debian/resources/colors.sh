#!/bin/sh

verbose () {
	echo "${green}$1${normal}"
}
error () {
	echo "${red}$1${normal}"
	}
warning () {
	echo "${yellow}$1${normal}"
}

# check for color support
if test -t 1; then

    # see if it supports colors...
    ncolors=$(tput colors)

    if test -n "$ncolors" && test $ncolors -ge 8; then
        normal="$(tput sgr0)"
        red="$(tput setaf 1)"
        green="$(tput setaf 2)"
        yellow="$(tput setaf 3)"
    fi
fi
