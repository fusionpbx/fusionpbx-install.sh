#!/bin/sh

# FusionPBX - Install
# Mark J Crane <markjcrane@fusionpbx.com>
# Copyright (C) 2018
# All Rights Reserved.
#
# Asks which method to issue the Let's Encrypt certificate with, then
# runs the matching script from the ssl/ directory:
#   ssl/dehydrated.sh  - uses dehydrated
#   ssl/certbot.sh      - uses certbot

#move to script directory so all relative paths work
cd "$(dirname "$0")" || exit 1

#includes
. ./config.sh
. ./colors.sh

#ask which script to run
printf "Choose the tool to build the SSL certificate?\n"
printf "  1) Certbot - Let's Encrypt\n"
printf "  2) Dehydrated - Let's Encrypt\n"
printf "Method [1]: "
read -r choice
[ -z "$choice" ] && choice=1

#run the selected script
case "$choice" in
        1 | certbot )
                ./ssl/certbot.sh
                ;;
        2 | letsencrypt )
                ./ssl/dehydrated.sh
                ;;
        * )
                error "Invalid choice: $choice"
                exit 1
                ;;
esac
exit $?


