#!/bin/bash


#Author: Yogendra 
#Version: 1.1

if [ $(id -u) -eq 0 ]                 # id -u returns the userid # of the user. 0 is for root

then

echo "Enter the username to add to the system"
read username					

echo "Checking the system if username exits ......"

sleep 2

egrep "^$username" /etc/passwd > /dev/null

if [ $? -eq 0 ]					# the exit code of the last command "egrep"

then

        echo "$username already exists!"

        exit 1					# your own exit code. will print the message with exit code of 1.

else

        echo "Adding $username as a new user"

fi


echo "Would you like to set up a password for $username right now? Enter either yes or no"

read answer

input=${answer,,}

if [ "$input" = "yes" ]

then

useradd -m  $username

passwd $username


[ $? -eq 0 ] && echo " User $username has been added to the system." || echo "Failed to add user $username to the system."

else

useradd $username

[ $? -eq 0 ] && echo " User $username has been added to the system." || echo "Failed to add user $username to the system."

fi

else 

echo "Only root can add user to the system"

fi
