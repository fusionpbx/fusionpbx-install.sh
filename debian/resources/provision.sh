#Selet What Phone Provision System to Install
###############################################################################
aastra="n" # : phone provisioning tool &  templates for aastra phones
atcom="n" # : phone provisioning tool &  templates for atcom phones
cisco="n" # : phone provisioning tool & templates for cisco phones
digium="n" # : phone provisioning tool & templates for digium phones
escene="n" # : phone provisioning tool & templates for escene phones
grandstream="n" # : phone provisioning tool & templates for grandstream phones
linksys="n" # : phone provisioning tool & templates for linksys phones
panasonic="n" # : phone provisioning tool & templates for panasonic phones
polycom="n" # : phone provisioning tool & templates for polycom phones
snom="n" # : provisioning tool & templates for snom phones
yealink="n" # : phone provisioning tool & templates for yealink phones
###############################################################################

if [[ $aastra == "y" ]]; then
	apt-get -y --force-yes install fusionpbx-app-devices fusionpbx-app-provision fusionpbx-provisioning-template-aastra  && mkdir -p /etc/fusionpbx/resources/templates/provision && cp -rp /usr/share/examples/fusionpbx/resources/templates/provision/aastra /etc/fusionpbx/resources/templates/provision/
fi

if [[ $atcom == "y" ]]; then
	apt-get -y --force-yes install fusionpbx-app-devices fusionpbx-app-provision fusionpbx-provisioning-template-atcom  && mkdir -p /etc/fusionpbx/resources/templates/provision && cp -rp /usr/share/examples/fusionpbx/resources/templates/provision/atcom /etc/fusionpbx/resources/templates/provision/
fi

if [[ $cisco == "y" ]]; then
	apt-get -y --force-yes install fusionpbx-app-devices fusionpbx-app-provision fusionpbx-provisioning-template-cisco && mkdir -p /etc/fusionpbx/resources/templates/provision && cp -rp /usr/share/examples/fusionpbx/resources/templates/provision/cisco /etc/fusionpbx/resources/templates/provision/
fi

if [[ $digium == "y" ]]; then
	apt-get -y --force-yes install fusionpbx-app-devices fusionpbx-app-provision fusionpbx-provisioning-template-digium && mkdir -p /etc/fusionpbx/resources/templates/provision && cp -rp /usr/share/examples/fusionpbx/resources/templates/provision/grandstream /etc/fusionpbx/resources/templates/provision/
fi

if [[ $escene == "y" ]]; then
	apt-get -y --force-yes install fusionpbx-app-devices fusionpbx-app-provision fusionpbx-provisioning-template-escene && mkdir -p /etc/fusionpbx/resources/templates/provision && cp -rp /usr/share/examples/fusionpbx/resources/templates/provision/grandstream /etc/fusionpbx/resources/templates/provision/
fi

if [[ $grandstream == "y" ]]; then
	apt-get -y --force-yes install fusionpbx-app-devices fusionpbx-app-provision fusionpbx-provisioning-template-grandstream && mkdir -p /etc/fusionpbx/resources/templates/provision && cp -rp /usr/share/examples/fusionpbx/resources/templates/provision/grandstream /etc/fusionpbx/resources/templates/provision/
fi

if [[ $linksys == "y" ]]; then
	apt-get -y --force-yes install fusionpbx-app-devices fusionpbx-app-provision fusionpbx-provisioning-template-linksys  && mkdir -p /etc/fusionpbx/resources/templates/provision && cp -rp /usr/share/examples/fusionpbx/resources/templates/provision/linksys /etc/fusionpbx/resources/templates/provision/
fi

if [[ $panasonic == "y" ]]; then
	apt-get -y --force-yes install fusionpbx-app-devices fusionpbx-app-provision fusionpbx-provisioning-template-panasonic  && mkdir -p /etc/fusionpbx/resources/templates/provision && cp -rp /usr/share/examples/fusionpbx/resources/templates/provision/panasonic /etc/fusionpbx/resources/templates/provision/
fi

if [[ $polycom == "y" ]]; then
	apt-get -y --force-yes install fusionpbx-app-devices fusionpbx-app-provision fusionpbx-provisioning-template-polycom && mkdir -p /etc/fusionpbx/resources/templates/provision && cp -rp /usr/share/examples/fusionpbx/resources/templates/provision/polycom /etc/fusionpbx/resources/templates/provision/
fi

if [[ $snom == "y" ]]; then
	apt-get -y --force-yes install fusionpbx-app-devices fusionpbx-app-provision fusionpbx-provisioning-template-snom && mkdir -p /etc/fusionpbx/resources/templates/provision && cp -rp /usr/share/examples/fusionpbx/resources/templates/provision/snom /etc/fusionpbx/resources/templates/provision/
fi

if [[ $yealink == "y" ]]; then
	apt-get -y --force-yes install fusionpbx-app-devices fusionpbx-app-provision fusionpbx-provisioning-template-yealink && mkdir -p /etc/fusionpbx/resources/templates/provision && cp -rp /usr/share/examples/fusionpbx/resources/templates/provision/yealink /etc/fusionpbx/resources/templates/provision/
fi
