#!/bin/bash 

# Extract and display only IP addresses, and not subnet mask or broadcast addresses.
# This method uses a sed piping into another sed. The first sed breaks out the IP addresses, and spaces the other information onto different lines
# Then, when the second sed comes along, it only grabs the IP Address line using a 'pattern' match, which is ultimately displayed via echo -e

# Check if ipInfo.sh is present
[[ ! -f ./ipInfo.sh ]] && echo -e "\033[31mERROR: ipInfo.sh is not present! \033[0m" && exit 1
# Check if ipInfo,sh is executable
[[ ! -x ./ipInfo.sh ]] && echo -e "\033[31mERROR: ipInfo.sh is not executable! \033[0m" && exit 2

# Sed the output of ipInfo.sh into a sed pattern match for only the IP Address: lines, which outputs to the terminal.
./ipInfo.sh | sed -n '/IP Address:/ {p}'