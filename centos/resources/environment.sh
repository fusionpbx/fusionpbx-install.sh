#!/bin/sh

#operating system details
os_name=$(uname -s)
os_version=$(uname -r)
os_mode='unknown'

#cpu details
cpu_name=$(uname -m)
cpu_architecture='unknown'
cpu_mode='unknown'

#check what the CPU and OS are
if [ .$cpu_name = .'armv7l' ]; then
	# RaspberryPi 3 is actually armv8l but current Raspbian reports the cpu as armv7l and no Raspbian 64Bit has been released at this time
	os_mode='32'
	cpu_mode='32'
	cpu_architecture='arm'
elif [ .$cpu_name = .'armv8l' ]; then
	# We currently have no test case for armv8l
	os_mode='unknown'
	cpu_mode='64'
	cpu_architecture='arm'
elif [ .$cpu_name = .'i386' ]; then
	os_mode='32'
	if [ "$(grep -o -w 'lm' /proc/cpuinfo)" = 'lm' ]; then
		cpu_mode='64'
	else
		cpu_mode='32'
	fi
	cpu_architecture='x86'
elif [ .$cpu_name = .'i686' ]; then
	os_mode='32'
	if [ "$(grep -o -w 'lm' /proc/cpuinfo)" = 'lm' ]; then
		cpu_mode='64'
	else
		cpu_mode='32'
	fi
	cpu_architecture='x86'
elif [ .$cpu_name = .'x86_64' ]; then
	os_mode='64'
	if [ "$(grep -o -w 'lm' /proc/cpuinfo)" = 'lm' ]; then
		os_mode='64'
	else
		os_mode='32'
	fi
	cpu_architecture='x86'
else
	error "You are using an unsupported cpu '$cpu_name'"
	exit 3
fi
	
if [ .$cpu_architecture = .'arm' ]; then
	error "CentOS on arm is not supported at this time"
	exit 3
elif [ .$cpu_architecture = .'x86' ]; then
	if [ .$os_mode = .'32' ]; then
		error "You are using a 32bit OS this is unsupported"
		if [ .$cpu_mode = .'64' ]; then
			warning " Your CPU is 64bit you should consider reinstalling with a 64bit OS"
		fi
		exit 3
	elif [ .$os_mode = .'64' ]; then
		verbose "Correct CPU and Operating System detected"
	else
		error "Unknown Operating System mode '$os_mode' is unsupported"
		warning "Detected environment was :-"
		warning "os_name:'$os_name'"
		warning "os_mode:'$os_mode'"
		warning "cpu_name:'$cpu_name'"
		warning "cpu_architecture:'$cpu_architecture'"
		exit 3
	fi
else
	error "You are using an unsupported architecture '$cpu_architecture'"
	warning "Detected environment was :-"
	warning "os_name:'$os_name'"
	warning "os_mode:'$os_mode'"
	warning "cpu_name:'$cpu_name'"
	exit 3
fi
