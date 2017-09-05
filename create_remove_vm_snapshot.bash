#!/bin/bash

#Author: Yogendra 
#Version: 1.3

# This script is used to create and delete a snapshot of a vm from OVM. 
# This will only delete snapshot of a vm taken using this script. It's likely to fail for other snapshots.

# Function that gives the option and keeps asking for input until the right number is chosen.
function option {
	echo -e "Choose whether to: \n
		1. Create a Snapshot \n
		2. Delete a Snapshot \n"
	read INPUT

	until [[ $INPUT -eq 1 || $INPUT -eq 2 ]]
	do
        	echo -e "Please enter either 1 or 2 \n"
		echo -e "Choose whether to: \n
                	1. Create a Snapshot \n
                	2. Delete a Snapshot \n"
        	read INPUT
	done

        if [ $INPUT -eq 1 ]
        then
                snapshot	# Calling the snapshot function.
        else
                delete		# Calling the delete function.
        fi
}

# The snapshot function
function snapshot {

	#First initialize the date. We need this to put it on the vm's name to keep track.
        DATE=$(date +"%m-%d-%y")

        #Ask user to enter the vm name to take the snapshot for.
        echo "Enter the vm name that needs snapshot....."
        read VM_NAME

        echo -e "Choose the Server Pool for the vm \n
                1. WON-LA1-NONPROD \n
                2. WON-LA1-PROD"
        read SERVER_POOL
	
	# Keep on asking until the right number is entered.
	until [[ $SERVER_POOL -eq 1 || $SERVER_POOL -eq 2 ]]
	do
		echo -e "Choose the Server Pool for the vm \n
               	 	1. WON-LA1-NONPROD \n
                	2. WON-LA1-PROD"
		read SERVER_POOL
	done

        if [ $SERVER_POOL -eq 1 ]
        then
		echo -e "Taking a snapshot.........\n"
    		sshpass -p "0vmgrW0n" ssh admin@10.230.48.53 -p 10000 clone Vm name=$VM_NAME destType=Vm destName=$VM_NAME-SNAP-$DATE serverPool=WON-LA1-NONPROD

        else [ $SERVER_POOL -eq 2 ]
        	echo -e "Taking a snapshot..........\n"
         	sshpass -p "0vmgrW0n" ssh admin@10.230.48.53 -p 10000 clone Vm name=$VM_NAME destType=Vm destName=$VM_NAME-SNAP-$DATE serverPool=WON-LA1-PROD
	fi
}

# The delete function
function delete {
	echo "Enter the vm name for which you would like to remove the snapshot"
	read VMNAME

	echo -e "The $VMNAME has the following snapshots: \n"

	# Store all the vm's snapshot in an array
	my_array=( $(sshpass -p "0vmgrW0n" ssh admin@10.230.48.53 -p 10000 list vm | grep $VMNAME-SNAP | awk '{print($3)}' | sed 's/name://') )

	count=1

	# For each snapshot display them in order starting from 1. This helps to get the input from the user so that we don't have to ask for specific snapshot name.

	for snapshot in "${my_array[@]}"
	do
		echo "$count. $snapshot"
		count=$(($count+1))
	done

	echo -e "Chose the number:"
	read NUM

	VM=${my_array[($NUM - $count)]}

	# Before deleting the vm the disk mappings needs to be deleted. List all the disk mapping for a vm and loop through them to delete the disk mapping.
	
	# This gives us the vm disk images.
	disk_list=( $(sshpass -p "0vmgrW0n" ssh admin@10.230.48.53 -p 10000  show Vm name=$VM | grep VmDiskMapping| awk '{print $10}' | tr -d '()]') )

	# This gives us the vm disk IDs.
	disk_id=( $(sshpass -p "0vmgrW0n" ssh admin@10.230.48.53 -p 10000  show Vm name=$VM | grep VmDiskMapping| awk '{print $5}') )

	echo -e "The disks associated with $VM are \n $disk_list \n"
	sleep 2
	
	echo -e "Deleting disk mappings and also the snapshot...............\n"
	sleep 2
	
	# Looping through the disk IDs to delete them.
	for disk in "${disk_id[@]}"
	do
		sshpass -p "0vmgrW0n" ssh admin@10.230.48.53 -p 10000 delete VmDiskMapping id=$disk
		sleep 2
	done
	
	# Finally deleting the vm.
	sshpass -p "0vmgrW0n" ssh admin@10.230.48.53 -p 10000 delete Vm name=$VM
}

option	# Calling the option function
