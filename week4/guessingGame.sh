#!/bin/bash

#This function prints a given error 
printError() 
{ 
	echo -e "\033[31mERROR:\033[0m $1"
} 

# Prompt for the number
getNumber() 
{ 
	read -p "$1: " 
	while (( $REPLY < $2 || $REPLY> $3 )); do 
	printError "Input must be between $2 and $3" 
	read -p "$1: " 
	done
}

# Loop infinitely until "42" is entered.
while [[ ! "$REPLY" -eq "42" ]]; do
    getNumber "please type a number between 1 and 100" 1 100
    if [[ "$REPLY" < 42 ]]; then # if too low, alert user answer is too low
        echo "Too low!"
    elif [[ "$REPLY" > 42 ]]; then # if too high, alert user is too high
        echo "Too high!"
    fi
done

# Inform the user they have guessed correctly
echo -e "\033[32mCorrect!\033[0m"