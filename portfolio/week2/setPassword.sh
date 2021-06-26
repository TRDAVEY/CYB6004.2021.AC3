#!/bin/bash

# Prompt ('-p') user for input using 'read' and hide their input using the silent ('-s') flag.
read -s -p "Please enter a password:" inputPassword
# Output an empty echo to create a new line after the read, so that the terminal doesn't become offset after the script has run.
echo ""
# Echo the sha256sum of the input into a text file called 'secret.txt'.
echo $inputPassword | sha256sum > secret.txt
