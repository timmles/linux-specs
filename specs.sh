#!/usr/bin/env bash

###################################################################
# Script Name	:   specs.sh
# Description	:   A simple starter script to find and print the basic specs of a linux machine.
# Args          :   None
# Author        :   Tim Lewis
# Email         :   mail@timlew.is
###################################################################
# TODOs and Considerations
# - This probably doesn't pull all the values you need.
#   But these underlying commands are extensive and have a lot of info - take a look at what else they provide
#   I've tried to comment each command so you can see what the underlying command is and how we awk those results to get what we need.
#   I've tried to keep the awk as simple as possible and use the underlying command to manipulate the output (e.g. "lsblk -n" removes the headers
#
# - This was only tested on an Ubuntu 18.04 machine. These commands may not be available in your distro
###################################################################

# dmidecode is used for dumpign system info in a human readable format
# dmidecode has an overview, set of data listed under specific types
# however to prevent having to grep or awk that data, they have keywords availble for specific sets of data

# using dmidecode special keyword for system system product name
make_model=$(sudo dmidecode -s system-product-name)

# using dmidecode special keyword for system serial number (there are plenty other types of SN available)
serial_number=$(sudo dmidecode -s system-serial-number)

# using dmidecode special keyword for processor version
processor=$(sudo dmidecode -s processor-version)

# using dmidecode processor information
# then awk with the delimiter as type ": ", with regex for exact words on that line (not from the start of the line because of dmidecode formating) and print 2nd column
core_count=$(sudo dmidecode -t processor | awk -F': ' '/Core Count/ {print($2);}')
thread_count=$(sudo dmidecode -t processor | awk -F': ' '/Thread Count/ {print($2);}')

# using free to display the amount of free and use memory
# -g, --gibi - Display the amount of memory in gibibytes.
#
# the pipe into awk and search for any line starting with Mem and grab the 2nd column
ram_size=$(free -g | awk '/^Mem/ {print($2);}')

# To figure out the size of the physical harddrive we use lsblk
# "-I 8" only include entries of type 8 - which is the code for physical disks
# -d, --nodeps - Do not print holder devices or slaves.  For example, lsblk --nodeps /dev/sda prints information about the sda device only.
# -n, --noheadings - Do not print a header line.
#
# then pipe the result to awk, and print only the 4th column, which holds the disk size
hdd_size=$(lsblk -I 8 -dn | awk '{print($4);}')

# using linux built in flag for a rotational drive, we can figure out if we have a spining drive
# is SSD = 0 | HDD = 0
if [ $(cat /sys/block/sda/queue/rotational) -eq 0 ];
    then hdd_type="SSD";
    else hdd_type="HDD";
fi

# adding some display swag
# tput setaf 1 - sets the colour to red
# tput bold - sets the font to bold
# tput sgr0 - sets back to terminal default

echo
echo '************************************************************'
echo "$(tput setaf 1 && tput bold) Make & Model: $(tput sgr0) $make_model"
echo "$(tput setaf 1 && tput bold) Serial number: $(tput sgr0) $serial_number"
echo "************************************************************"
echo "$(tput setaf 1 && tput bold) CPU: $(tput sgr0) $processor"
echo "$(tput setaf 1 && tput bold) Core count: $(tput sgr0) $core_count"
echo "$(tput setaf 1 && tput bold) Thread count: $(tput sgr0) $thread_count"
echo "$(tput setaf 1 && tput bold) RAM size: $(tput sgr0) ${ram_size}GB"
echo "$(tput setaf 1 && tput bold) HDD size: $(tput sgr0) $hdd_size"
echo "$(tput setaf 1 && tput bold) HDD type: $(tput sgr0) $hdd_type"
echo "************************************************************"
echo
echo
echo "Make & Model", "Serial number", "CPU", "Core count", "Thread count", "RAM size", "HDD size", "HDD type"
echo $make_model, $serial_number, $processor, $core_count, $thread_count, $ram_size GB, $hdd_size, $hdd_type
