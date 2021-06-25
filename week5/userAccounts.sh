#!/bin/bash

# Outputs a table depicting all users on the system that use bash as a shell.
# All output is formatted as a standard formatted table with width modifiers
# All text is left justified

awk -F: 'BEGIN{
    # Print headings - Each heading wrapped in blue colouring
    printf("| %s%-15s%s | %s%-10s%s | %s%-10s%s | %s%-15s%s | %s%-15s%s |\n",
    # Username
    "\033[34m", "Username","\033[0m",
    # UserID
    "\033[34m", "UserID","\033[0m",
    # GroupID
    "\033[34m", "GroupID","\033[0m",
    # Home
    "\033[34m", "Home","\033[0m",
    # Shell
    "\033[34m","Shell", "\033[0m")

    # Print lower line of the table below the headings
    printf("| %-15s | %-10s | %-10s | %-15s | %-15s |\n",
        "_______________",
        "__________",
        "__________",
        "_______________",
        "_______________")
}

# For each line that contains /bin/bash, print the following table:
/\/bin\/bash$/ {
    printf("| %-15s | %-10s | %-10s | %-15s | %-15s |\n",
    $1,
    $3,
    $4,
    $6,
    $7)
}
' /etc/passwd