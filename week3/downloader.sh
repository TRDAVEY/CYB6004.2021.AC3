#!/bin/bash

# Repeat forever
while true
do
    # Get URL from user input
    echo -e "Please type the URL of a file to download, or type 'exit' to quit: "
    read inputURL

    ## if 'exit' then exit the script
    if [ "$inputURL" = "exit" ]; then
        exit 0
    fi
    # Get download location
    echo -e "Type the location of where you would like to download the file to: "
    read inputDownloadLocation

    # Test if this location is a directory
    if [[ ! -d "$inputDownloadLocation" ]]; then
        echo -e "\033[31mERROR: Please enter a valid download location! \033[0m"
        continue # invalid download location - Go back to the top of the loop and try again,
    fi

    ## else download the url passed with wget
    wget -P $inputDownloadLocation $inputURL
done