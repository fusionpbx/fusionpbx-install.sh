#!/bin/sh

#make sure lsb release is installed
apt-get install lsb-release

#operating system details
os_name=$(lsb_release -is)
os_codename=$(lsb_release -cs)
os_mode='unknown'

#cpu details
cpu_name=$(uname -m)
cpu_architecture='unknown'
cpu_mode='unknown'

#set the environment path
export PATH=$PATH:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

#check what the CPU and OS are
if [ .$cpu_name = .'armv6l' ]; then
	# RaspberryPi Zero
	os_mode='32'
	cpu_mode='32'
	cpu_architecture='arm'
elif [ .$cpu_name = .'armv7l' ]; then
	# RaspberryPi 3 is actually armv8l but current Raspbian reports the cpu as armv7l and no Raspbian 64Bit has been released at this time
	os_mode='32'
	cpu_mode='32'
	cpu_architecture='arm'
elif [ .$cpu_name = .'armv8l' ]; then
	# No test case for armv8l
	os_mode='unknown'
	cpu_mode='64'
	cpu_architecture='arm'
elif [ .$cpu_name = .'aarch64' ]; then
	os_mode='64'
	cpu_mode='64'
	cpu_architecture='arm'
elif [ .$cpu_name = .'i386' ]; then
	os_mode='32'
	if [ .$(grep -o -w 'lm' /proc/cpuinfo | head -n 1) = .'lm' ]; then
		cpu_mode='64'
	else
		cpu_mode='32'
	fi
	cpu_architecture='x86'
elif [ .$cpu_name = .'i686' ]; then
	os_mode='32'
	if [ .$(grep -o -w 'lm' /proc/cpuinfo | head -n 1) = .'lm' ]; then
		cpu_mode='64'
	else
		cpu_mode='32'
	fi
	cpu_architecture='x86'
elif [ .$cpu_name = .'x86_64' ]; then
	os_mode='64'
	if [ .$(grep -o -w 'lm' /proc/cpuinfo | head -n 1) = .'lm' ]; then
		cpu_mode='64'
	else
		cpu_mode='32'
	fi
	cpu_architecture='x86'
else
	error "You are using an unsupported cpu '$cpu_name'"
	exit 3
fi

if [ .$cpu_architecture = .'arm' ]; then
	if [ .$os_mode = .'32' ]; then
		verbose "Correct CPU and Operating System detected, using the ARM repo"
	elif [ .$os_mode = .'64' ]; then
		error "You are using a 64bit arm OS this is unsupported"
		switch_source=true
		switch_package=false
	else
		error "Unknown OS mode $os_mode this is unsupported"
		switch_source=true
		switch_package=false
	fi
elif [ .$cpu_architecture = .'x86' ]; then
	if [ .$os_mode = .'32' ]; then
		error "You are using a 32bit OS this is unsupported"
		if [ .$cpu_mode = .'64' ]; then
			warning " Your CPU is 64bit you should consider reinstalling with a 64bit OS"
		fi
		switch_source=true
		switch_package=false
	elif [ .$os_mode = .'64' ]; then
		verbose "Correct CPU and Operating System detected"
	else
		error "Unknown Operating System mode '$os_mode' is unsupported"
		switch_source=true
		switch_package=false
	fi
else
	error "You are using an unsupported architecture '$cpu_architecture'"
	warning "Detected environment was :-"
	warning "os_name:'$os_name'"
	warning "os_codename:'$os_codename'"
	warning "os_mode:'$os_mode'"
	warning "cpu_name:'$cpu_name'"
	exit 3
fi
