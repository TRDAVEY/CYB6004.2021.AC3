#/bin/bash

# Run passwordCheck.sh to prompt for user password and compare to stored hash
./passwordCheck.sh

# Check if passwordCheck.sh was successful (exitcode 0)
if [ $? = 0 ]; then
    # Passwords match, print menu options (echo -e allows for escaped characters like \n create new lines, to print across multiple lines)
    echo -e "Select an option:\n1. Create a folder\n2. Copy a folder\n3. Set a password"
    # read user input for their selection of menu option
    read menuOption
    
    # Check the user entry compared to the menu options, and fail if they do not succeed
    case $menuOption in
        1)
            # Option 1 - Run folderMaker.sh
            ./folderMaker.sh
            ;;
        2)
            # Option 2 - Run folderCopier.sh
            ./folderCopier.sh
            ;;
        3)
            # Option 3 - Run setPassword.sh
            ./setPassword.sh
            ;;
        *)
            # If an invalid entry is given, error out
            echo "Incorrect menu option. Please make a valid selection"
            exit 1
            ;;
    esac
else
    # If the exit code is anything other than 0, bid the user goodbye
    echo "Goodbye"
fi
