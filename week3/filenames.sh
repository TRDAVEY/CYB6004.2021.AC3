#!/bin/bash

# Error if no argument given
if (( $#!=1 )); then 
 echo -e "\033[31m ERROR: No Filenames given! \033[0m"
 exit 1 
fi

# Error if argument is not a file
if [[ -f "$1" ]]; then
    # Whilst this script is after talks of FOR loops, I will use a while loop...
    # Iterate through each line, ensuring to get the final line without using a tailing newline
    while read line || [[ -n $line ]];
    do
        # Test the line for file, directory or other
        if [[ -f $line ]]; then
            # If line is a File
            echo $line - "That file exists"
        elif [[ -d $line ]]; then
            # If line is a Directory
            echo $line - "That's a directory"
        else
            # Otherwise, it is unknown
            echo $line - "I don't know what that is!"
        fi
    done < $1
    #     ^^^ the filenames.txt file is passed into the loop here
else
    # Argument is not a file!
    echo -e "\033[31m ERROR: Argument is not a file! \033[0m"
    exit 2
fi

