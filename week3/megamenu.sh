#/bin/bash

# Run passwordCheck.sh to prompt for user password and compare to stored hash
./passwordCheck.sh

# Check if passwordCheck.sh was successful (exitcode 0)
if [ $? = 0 ]; then
    # Repeat forever
    while true
    do
            # Print menu options
            echo -e "\033[34mSelect an option:"
            echo -e "\033[36m1. Create a folder"
            echo -e "2. Copy a folder"
            echo -e "3. Set a password"
            echo -e "4. Calculator"
            echo -e "5. Create Week Folders"
            echo -e "6. Check Filenames"
            echo -e "7. Download a File\033[0m"
            echo -e "8. Exit"
            # read user input for their selection of menu option
            read menuOption
            
            # Check the user entry compared to the menu options, and fail if they do not succeed
            case $menuOption in
                1)
                    # Option 1 - Run folderMaker.sh
                    ../week2/folderMaker.sh
                    ;;
                2)
                    # Option 2 - Run folderCopier.sh
                    ../week2/folderCopier.sh
                    ;;
                3)
                    # Option 3 - Run setPassword.sh
                    ./setPassword.sh
                    ;;
                4)
                    # Option 4 - Run calculator.sh
                    ./calculator.sh
                    ;;
                5)
                    # Option 5 - Run megafoldermaker.sh - hardcoded for 'week' 7 and 8 as otherwise people can't pass arguments, and I don't want to overwrite folders...
                    ./megafoldermaker.sh 7 8
                ;;
                6)
                    # Option 6 - Run filenames.sh - Hardcoded to check filenames.txt as once again, users cannot pass arguments
                    ./filenames.sh filenames.txt
                ;;
                7)
                    # Option 7 - Run downloader.sh
                    ./downloader.sh
                ;;
                8)
                    # Option 8 - Exit gracefully
                    exit 0
                    ;;
                *)
                    # If an invalid entry is given, error out
                    echo -e "\033[31mIncorrect menu option. Please make a valid selection\033[0m"
                    continue
                    ;;
            esac

    done
else
    # If the exit code is anything other than 0, bid the user goodbye
    echo "Goodbye"
fi