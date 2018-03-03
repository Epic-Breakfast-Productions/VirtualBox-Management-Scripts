#!/bin/bash
# This script automatically sets up a virtual machine to be run on startup of the host.

errVal="<>";

vmName="";

function showHelp(){
	echo "Help output:";
	echo;

}

while getopts "n:m:d:N:a:i:f:" opt; do
	case $opt in
		h|\?)
		showHelp;
		;;
		n)
		vmName=$OPTARG;
		;;
	esac
done

echo "Setting up VM named \"$vmName\" to be auto started up/ brought down with host system.";

# TODO: setup test to see if setup file exists. If not, setup file to be run on start/shutdown



#TODO: setup to automatically add the vm to the list of vms to start

