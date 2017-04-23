#!/bin/sh

#operating system details
os_name=$(uname -s)
os_version=$(uname -r)
os_mode='unknown'
os_test=$(uname -m)
cpu_architecture='unknown'

#check what the CPU and OS are
	cpu_name='unknown'
	cpu_mode='unknown'
	if [ .$cpu_name = .'armv7l' ]; then
		os_mode='32'
		cpu_mode='32'
		# RaspberryPi 3 is actually armv8l but current Raspbian reports the cpu as armv7l and no Raspbian 64Bit has been released at this time
		cpu_architecture='arm'
	elif [ .$cpu_name = .'armv8l' ]; then
		# We currently have no test case for armv8l
		os_mode='unknown'
		cpu_name='64'
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
			verbose "Correct CPU/OS detected"
		else
			error "Unknown os_mode $os_mode this is unsupported"
			exit 3
		fi
	else
		error "You are using a unsupported architecture $cpu_architecture"
	fi
fi
