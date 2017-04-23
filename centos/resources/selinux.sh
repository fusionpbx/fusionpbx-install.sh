#!/bin/sh

# Disable SELinux
verbose "Disabling SELinux"
warning "Reboot required after installation completes"
setenforce 0
sed -i 's/\(^SELINUX=\).*/\SELINUX=disabled/' /etc/selinux/config
verbose "SELinux disabled"
