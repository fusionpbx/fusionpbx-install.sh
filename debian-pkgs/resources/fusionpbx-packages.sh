#Select Optional Addon Pkgs
######################################################################################################################
adminer="y" # : integrated for an administrator in the superadmin group to enable easy database access
backup="y" # : pbx backup module. backup sqlite db / configs/ logs
call_broadcast="n" # : Create a recording and select one or more groups to have the system call and play the recording
call_center="y" # : display queue status, agent status, tier status for call centers using mod_callcenter call queues
call_flows="n" # : Typically used with day night mode. To direct calls between two destinations.
conference_centers="n" # : tools for multi room confrences and room contol
conferences="n" # : tools for single room confrences and room contol
edit="y" # : multi tools for editing (templates/xmlfiles/configfiles/scripts) files
exec="n" # : comman shells pages for executing (php/shells) commands
fax="y" # : fusionpbx send/recieve faxes service
fifo="n" # : first in first out call queues system
services="n" # : allows interaction with the processes running on your server
traffic_graph="n" # : php graph for monitoing the network interface traffic
#####################################################################################################################

if [[ $adminer == "y" ]]; then
	apt-get -y --force-yes install fusionpbx-app-adminer
fi

if [[ $backup == "y" ]]; then
	apt-get -y --force-yes install fusionpbx-app-backup
fi

if [[ $call_broadcast == "y" ]]; then
	apt-get -y --force-yes install fusionpbx-app-call-broadcast
fi

if [[ $call_center == "y" ]]; then
	apt-get -y --force-yes install fusionpbx-app-call-center fusionpbx-app-call-center-active
		if [[ -f /root/.fs_src ]] ; then
			if [[ ! -f /usr/lib/freeswitch/mod/mod_callcenter ]] ; then
				echo " Requires freeswitch mod_callcenter "
			fi
		else
			apt-get -y --force-yes install freeswitch-mod-callcenters
		fi
fi

if [[ $call_flows == "y" ]]; then
	apt-get -y --force-yes install fusionpbx-app-call-flows
fi

if [[ $conference_centers == "y" ]]; then
	apt-get -y --force-yes install freeswitch-mod-conference fusionpbx-app-conference-centers fusionpbx-app-conferences-active fusionpbx-app-meetings
		if [[ -f /root/.fs_src ]] ; then
			if [[ ! -f /usr/lib/freeswitch/mod/mod_conference ]] ; then
				echo " Requires freeswitch mod_conference "
			fi
		else
			apt-get -y --force-yes install freeswitch-mod-conferences
		fi
fi

if [[ $conference == "y" ]]; then
	apt-get -y --force-yes install freeswitch-mod-conference fusionpbx-app-conferences fusionpbx-app-conferences-active fusionpbx-app-meetings
		if [[ -f /root/.fs_src ]] ; then
			if [[ ! -f /usr/lib/freeswitch/mod/mod_conference ]] ; then
				echo " Requires freeswitch mod_conference "
			fi
		else
			apt-get -y --force-yes install freeswitch-mod-conferences
		fi
fi

if [[ $edit == "y" ]]; then
	apt-get -y --force-yes install fusionpbx-app-edit
fi

if [[ $exec == "y" ]]; then
	apt-get -y --force-yes install fusionpbx-app-exec
fi

if [[ $fax == "y" ]]; then
	apt-get -y --force-yes install ghostscript libreoffice-common fusionpbx-app-fax
fi

if [[ $fifo == "y" ]]; then
	apt-get -y --force-yes install freeswitch-mod-fifo fusionpbx-app-fifo fusionpbx-app-fifo-list
		if [[ -f /root/.fs_src ]] ; then
			if [[ ! -f /usr/lib/freeswitch/mod/mod_fifo ]] ; then
				echo " Requires freeswitch mod_fifo "
			fi
		else
			apt-get -y --force-yes install freeswitch-mod-fifo
		fi
fi

if [[ $services == "y" ]]; then
	apt-get -y --force-yes install fusionpbx-app-services
fi

if [[ $traffic_graph == "y" ]]; then
	apt-get -y --force-yes install fusionpbx-app-traffic-graph
fi
