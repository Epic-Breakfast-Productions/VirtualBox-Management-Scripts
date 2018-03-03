#!/bin/bash

# this script creates a vm.

errVal="<>";

defaultVmName="$errVal";

# the location of VirtualBox's VM's
virtualBoxMachineFolder=~/VirtualBox\ VMs/;

# the name of the vm to make.
vmName=$defaultVmName;

# the amount of memory to give the vm.
memCount=2048;

# the size of the harddrive to give.
hdSize=10000;

# The nic mode, i.e. bridged.
nicMode="bridged";

#The adapter for bridged mode.
nicAdapter="$errVal";

# The ISO to mount to the dvd drive.
iso="$errVal";

function showVmDetails(){
	echo;
	echo;
	echo "VM Info: (all sizes are in Megabytes)";
	echo "  Name:                 \"$vmName\"";
	echo "  Memory:               $memCount";
	echo "  Harddrive Size:       $hdSize";
	echo "  NIC Mode / interface: $nicMode / $nicAdapter";
	echo;
	echo "  VM Location:          $virtualBoxMachineFolder";
	echo "  ISO Location:         $iso";
	echo;
	echo;
}

function showHelp(){
	echo "Help output:";
	echo;
	echo "Details of vm creation:";
	echo "	- ";
	echo;
	echo;
	echo "Operands: (* = required.)(All number values are in megabytes)";
	echo "	-h";
	echo "	Shows this help. Exits.";
	echo;
	echo "	-n <name of vm>";
	echo "	* The name of the VM to create. If not specified, cannot continue.";
	echo;
	echo "	-m <amount of RAM>";
	echo "	Specify the amount of ram the vm should have. Default $memCount";
	echo;
	echo "	-d <size of harddrive>";
	echo "	Specify the harddrive size for the VM. Default $hdSize";
	echo;
	echo "	-N <nicMode>";
	echo "	Specify the nic mode for the vm. Default \"$nicMode\"";
	echo;
	echo "	-a <The adapter to use for the nic>";
	echo "	* The name of the physical card of the host machine to use. If not specified, skips setting up nic.";
	echo;
	echo "	-i <location of iso to mount>";
	echo "	* The location/name of the iso to mount in the dvd drive. Skips this step if not specified.";
	echo;
	echo "	-f <location of folder to put vm>";
	echo "	Changes the default location to put the vm. Default: $virtualBoxMachineFolder";
	echo;
	echo "Exiting.";
	echo;
	exit 0;
}


while getopts "n:m:d:N:a:i:f:" opt; do
	case $opt in
		h|\?)
		showHelp;
		;;
		n)
		vmName=$OPTARG;
		;;
		m)
		memCount=$OPTARG;
		;;
		d)
		hdSize=$OPTARG;
		;;
		N)
		$nicMode=$OPTARG;
		;;
		a)
		nicAdapter=$OPTARG;
		;;
		i)
		iso=$OPTARG;
		;;
		f)
		virtualBoxMachineFolder=$OPTARG;
		;;
	esac
done

echo "Vbox machine folder: $virtualBoxMachineFolder";
showVmDetails;

if [ ! -d "$virtualBoxMachineFolder"  ]; then
	echo "INVALID VM folder given. Does it exist?";
	exit 1;
fi

if [ "$vmName" == "$errVal" ]; then
	echo "INVALID VM name given.";
	exit 1;
fi

if [[ ! -e "$iso" || "$iso" == "$errVal" ]]; then
	echo "INVALID ISO location given. Can continue, but will skip mounting ISO.";
fi

if [ "$nicAdapter" == "$errVal" ]; then
	# TODO: ensure this is a valid card
	echo "INVALID host networking adapter given. Can continue, but will not configure NIC.";
fi

# TODO: Check memory count
#TODO: check disk size

echo;
read -p "Confirm settings and continue? [Yy] " -n 1 -r
echo    # (optional) move to a new line
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
	[[ "$0" = "$BASH_SOURCE" ]] && exit 1 || return 1 # handle exits from shell or function but don't exit interactive shell
fi

vmFolder="$virtualBoxMachineFolder$vmName";

#############
# create vm #
#############
VBoxManage createvm --name "$vmName" --register


##############################
# setup memory and dvd drive #
##############################
VBoxManage modifyvm "$vmName" --memory $memCount
VBoxManage modifyvm "$vmName" --acpi on --boot1 dvd


#TODO: if valid do this
#############
# setup nic #
#############
VBoxManage modifyvm --nic1 $nicMode --bridgeadapter1 $nicAdapter


#######################
# setup virtual drive #
#######################
smve="$vmFolder/$vmName.vdi";
storageCtlName="IDE Controller";

VBoxManage createhd --filename "$vmDrive" --size $hdSize
VBoxManage storagectl "$vmName" --name "$storageCtlName" --add ide
VBoxManage storageattach "$vmName" --storagectl "$storageCtlName" --port 0 --device 0 --type hdd --medium "$vmDrive"

##########################
# Setup ISO on dvd drive #
##########################
if [[ ! -e "$iso" || "$iso" == "$errVal" ]]; then
	VBoxManage storageattach "$vmName" --storagectl "$storageCtlName" --port 1 --device 0 --type dvddrive --medium "$iso"
else
	echo;
	echo "Run the following command to setup an ISO:";
	echo "	VBoxManage storageattach \"$vmName\" --storagectl \"$storageCtlName\" --port 1 --device 0 --type dvddrive --medium \"<iso location>\"";
	echo;
fi

########
# Misc #
########
VBoxManage modifyvm "$vmName" --vrde on


echo;
echo;
echo "Script completed.";
showVmDetails;
echo "Tips:";
echo "	Use the following command to run the VM:";
echo "		VBoxHeadless --startvm $vmName";
echo;
echo;

