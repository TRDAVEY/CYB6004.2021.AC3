#!/bin/bash

# Outputs a table depicting all users on the system that use bash as a shell.
# All output is formatted as a standard formatted table with width modifiers
# All text is left justified



awk -F: 'BEGIN{
    # Print headings - Each heading wrapped in blue colouring
    printf("| %s%-18s%s | %s%-10s%s | %s%-10s%s | %s%-22s%s | %s%-20s%s |\n",
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
    printf("|%-18s|%-10s|%-10s|%-22s|%-20s|\n",
        "____________________",
        "____________",
        "____________",
        "________________________",
        "______________________")
}

# For each line print the following table:
{
    printf("| %s%-18s%s | %s%-10s%s | %s%-10s%s | %s%-22s%s | %s%-20s%s |\n",
    "\033[33m",$1,"\033[0m",
    "\033[35m",$3,"\033[0m",
    "\033[35m",$4,"\033[0m",
    "\033[35m",$6,"\033[0m",
    "\033[35m",$7,"\033[0m")
}
' /etc/passwd