#!/bin/bash

# Path to be checked
scanDir="../"

echo $(basename $scanDir)

# All sed statements
echo -e "\033[31m------------ All sed statements ------------"
grep -r "sed" "$scanDir"

# All lines that start with the letter m
echo -e "\033[32m------------ All lines starting with the letter m ------------"
grep -r "^m" "$scanDir"

# All lines that contain three digit numbers
echo -e "\033[34m------------ All lines that contain three digit numbers ------------"
grep -r -P "[0-9]{3}" "$scanDir"

# All echo statements with at least three words
echo -e "\033[35m------------ All echo statements with at least three words ------------"
grep -r -P "echo\ *\".+\ .+\ .+"\" "$scanDir"

# All lines that would make a good password (lower case, upper case, numbers, special characters) and at least 12 characters long
# Flags: -r - Recursive | -o - Show only matching | P - Use Perl regex | -I - Effectively ignore binary files
echo -e "\033[33m------------ All strings that would make good passwords ------------"
grep -roPI "^(?=.*[A-z)(?=.*[a-z)(?=.*[A-Z])(?=.*[0-9])(?=.*[!@#$%^&*()_+])\S{12,}\z" "$scanDir"