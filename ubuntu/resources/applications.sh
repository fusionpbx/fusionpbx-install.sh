#!/bin/sh

#move to script directory so all relative paths work
cd "$(dirname "$0")"

#includes
. ./config.sh

#optional applications
cd /var/www/fusionpbx/app
if [ .$application_transcribe = .'true' ]; then
	git clone https://github.com/fusionpbx/fusionpbx-app-transcribe.git transcribe
fi
if [ .$application_speech = .'true' ]; then
	git clone https://github.com/fusionpbx/fusionpbx-app-speech.git speech
fi
if [ .$application_device_logs = .'true' ]; then
	git clone https://github.com/fusionpbx/fusionpbx-app-device_logs.git device_logs
fi
if [ .$application_dialplan_tools = .'true' ]; then
	git clone https://github.com/fusionpbx/fusionpbx-app-dialplan_tools.git dialplan_tools
fi
if [ .$application_edit = .'true' ]; then
	git clone https://github.com/fusionpbx/fusionpbx-app-dialplan_tools.git edit
fi
if [ .$application_sip_trunks = .'true' ]; then
	git clone https://github.com/fusionpbx/fusionpbx-app-sip_trunks.git sip_trunks
fi
chown -R www-data:www-data /var/www/fusionpbx