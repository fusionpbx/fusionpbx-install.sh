#!/bin/sh

#operating system details
os_name=$(uname -s)
os_version=$(uname -r)
os_mode='unknown'

#cpu details
cpu_name=$(uname -m)
cpu_architecture='unknown'
cpu_mode='unknown'
