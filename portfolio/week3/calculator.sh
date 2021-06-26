#!/bin/bash

# Initiate inputNumbers
inputNumberA=0
inputNumberB=0

#Initiate outputResult
outputResult=0

# Initiate outputColour variable
outputColour="\033[0m"

# Ask user for arithmatic operation (Add, subtract, divide, multiply)
echo -e $outputColour"Please select an operation:\n\033[34m1. Addition\n\033[32m2. Subtraction\n\033[31m3. Multiplication\n\033[35m4. Division\033[0m"
read inputOperation

# Ask for input values
echo -e "Please input your first number:"
read inputNumberA

echo -e "Please input your second number:"
read inputNumberB

# Output the result, coloured by the appropriate colour code
# Add - Blue
# Subtract - Green
# Multiplication - Red
# Division - Purple
case $inputOperation in
        1)
            #Addition - set the outputColour and calculate the result
            outputColour="\033[34m"
            outputResult=$(echo "scale = 2; "$inputNumberA + $inputNumberB | bc)
        ;;

        2)
            #Subtraction - set the outputColour and calculate the result
            outputColour="\033[32m"
            outputResult=$(echo "scale = 2; "$inputNumberA - $inputNumberB | bc)
        ;;

        3)
            #Multiplication - set the outputColour and calculate the result
            outputColour="\033[31m"
            outputResult=$(echo "scale = 2; "$inputNumberA \* $inputNumberB | bc)
        ;;

        4)
            #Division
            outputColour="\033[35m"
            # If a division, check if one of the two is a zero
            if [ "$inputNumberA" -eq "0" ] || [ "$inputNumberB" -eq "0" ] 
            then
                echo "ERROR: Cannot divide by zero!"
                exit 2
            else
                outputResult=$(echo "scale = 2; "$inputNumberA / $inputNumberB | bc)
            fi
        ;;

        *)
            #Invalid selection
            echo "Invalid Operation selection! Please try again."
            exit 1
        ;;
esac

# Output the answer, using the appropriate colour
echo -e $outputColour"================================="
echo -e "Your answer is: "$outputResult
echo -e "================================="

# Re-run the script so the user can continue to calculate things
/bin/bash $0