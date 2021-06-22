#!/bin/bash

# Ask for user's password to be checked.
read -s -p "Please enter your password:" inputPassword

# Echo a blank line to tidy up
echo ""

# sha256sum the inputPassword by echoing it into sha256sum, and then storing it within inputPassword again.
inputPassword=$(echo $inputPassword | sha256sum)

# read and store the contents of secret.txt, which is assumed to exist.
storedPassword=$(cat secret.txt)

# Test to see if inputPassword and storedPassword are a match (Variables are wrapped in quotes so that they aren't taken literally, 
# and equality is checked with a single = sign when in a single bracket [] test)
if [ "$inputPassword" = "$storedPassword" ];
then
    # Password hashes match, output that access is granted and exit with a 0 error code (success)
    echo "Access Granted"
    exit 0
else
    # Password hashes do not match, output that access is denied and exit with a 1 error code (fail)
    echo "Access Denied"
    exit 1
fi
