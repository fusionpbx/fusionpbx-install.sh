#!/bin/sh

#Process command line options only if we haven't been processed once
if [ -z "$CPU_CHECK" ]; then
	export script_name=`basename "$0"`
	ARGS=$(getopt -n '$script_name' -o h -l help,use-switch-source,use-switch-package-all,use-switch-master,use-switch-package-unofficial-arm,use-php5-package,use-system-master,no-cpu-check -- "$@")
	
	if [ $? -ne 0 ]; then
		error "Failed parsing options."
		exit 1
	fi
	
	export USE_SWITCH_SOURCE=false
	export USE_SWITCH_PACKAGE_ALL=false
	export USE_SWITCH_PACKAGE_UNOFFICIAL_ARM=false
	export USE_PHP5_PACKAGE=false
	export USE_SWITCH_MASTER=false
	export USE_SYSTEM_MASTER=false
	export CPU_CHECK=true
	HELP=false
	
	while true; do
	  case "$1" in
		--use-switch-source ) export USE_SWITCH_SOURCE=true; shift ;;
		--use-switch-package-all ) export USE_SWITCH_PACKAGE_ALL=true; shift ;;
		--use-switch-master ) export USE_SWITCH_MASTER=true; shift ;;
		--use-system-master ) export USE_SYSTEM_MASTER=true; shift ;;
		--use-php5-package ) export USE_PHP5_PACKAGE=true; shift ;;
		--use-switch-package-unofficial-arm ) export USE_SWITCH_PACKAGE_UNOFFICIAL_ARM=true; export USE_PHP5_PACKAGE=true; shift ;;
		--no-cpu-check ) export CPU_CHECK=false; shift ;;
		-h | --help ) HELP=true; shift ;;
		-- ) shift; break ;;
		* ) break ;;
	  esac
	done
	
	if [ .$HELP = .true ]; then
		warning "Debian installer script"
		warning "	--use-switch-source will use freeswitch from source rather than ${green}(default:packages)"
		warning "	--use-switch-package-all if using packages use the meta-all package"
		warning "	--use-switch-package-unofficial-arm if your system is arm and you are using packages, use the unofficial arm repo and force php5* packages"
		warning "	--use-php5-package use php5* packages instead of ${green}(default:php7.0)"
		warning "	--use-switch-master will use master branch/packages for the switch instead of ${green}(default:stable)"
		warning "	--use-system-master will use master branch/packages for the system instead of ${green}(default:stable)"
		warning "	--no-cpu-check disable the cpu check ${green}(default:check)"
		exit;
	fi
fi