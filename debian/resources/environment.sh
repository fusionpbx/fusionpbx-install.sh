#!/bin/sh

#check what the CPU and OS are
cpu_name=$(uname -m)
cpu_architecture='unknown'
cpu_mode='unknown'
os_mode = 'unknown'

if [ .$cpu_name = .'armv7l' ]; then
	# RaspberryPi 3 is actually armv8l but current Raspbian reports the cpu as armv7l and no Raspbian 64Bit has been released at this time
	os_mode='32'
	cpu_mode='32'
	cpu_architecture='arm'
elif [ .$cpu_name = .'armv8l' ]; then
	# No test case for armv8l
	os_mode='unknown'
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
fi


if [ .$cpu_architecture = .'arm' ]; then
	if [ .$os_mode = .'32' ]; then
		#export USE_SWITCH_PACKAGE_UNOFFICIAL_ARM=true
		verbose "Correct CPU/OS detected, using unofficial arm repo"
	elif [ .$os_mode = .'64' ]; then
		error "You are using a 64bit arm OS this is unsupported"
		warning " please rerun with --use-switch-source"
		exit 3
	else
		error "Unknown OS_bits $OS_bits this is unsupported"
		warning " please rerun with --use-switch-source"
		exit 3
	fi
elif [ .$cpu_architecture = .'x86' ]; then
	if [ .$os_mode = .'32' ]; then
		error "You are using a 32bit OS this is unsupported"
		if [ .$cpu_mode = .'64' ]; then
			warning " Your CPU is 64bit you should consider reinstalling with a 64bit OS"
		fi
		warning " please rerun with --use-switch-source"
		exit 3
	elif [ .$os_mode = .'64' ]; then
		verbose "Correct CPU/OS detected"
	else
		error "Unknown OS_bits $OS_bits this is unsupported"
		warning " please rerun with --use-switch-source"
		exit 3
	fi
else
	error "You are using a unsupported architecture $cpu_architecture"
fi
