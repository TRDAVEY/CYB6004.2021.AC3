#!/bin/bash 

# Extract and display only IP addresses, and not subnet mask or broadcast addresses.
# This method uses a sed piping into another sed. The first sed breaks out the IP addresses, and spaces the other information onto different lines
# Then, when the second sed comes along, it only grabs the IP Address line using a 'pattern' match, which is ultimately displayed via echo -e
addresses=$(ifconfig | sed -n '/inet / { 
s/inet/IP Address:/ 
s/netmask/\n/ 
s/broadcast/\n/ 

p
}' | sed -n '/IP Address:/ {p}')

# Output the found IP addresses, and nothing else.
echo -e "$addresses" 