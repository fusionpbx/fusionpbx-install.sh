#!/bin/sh

#operating system details
os_name=$(freebsd-version -u)
os_mode='unknown'

#cpu details
cpu_name=$(uname -m)
cpu_architecture='unknown'
cpu_mode='unknown'
