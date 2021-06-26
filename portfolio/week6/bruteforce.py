#!/usr/bin/python3

import string # Allow the use of the string class
import hashlib # Allow hashing (sha256 in this case)

# targetPassword - The plaintext representation of the password we aim to find
targetPassword = "asd"
# targetPasswordHash - The sha256 hash of the targetPassword
targetPasswordHash = hashlib.sha256(targetPassword.encode("utf-8")).hexdigest()
# Whether the password has been cracked
isCracked = False
# number of attemps to crack
pwAttempts = 0

# All possibly typed characters - may need to be cut down for the sake of speed in this instance
possiblechars = string.ascii_lowercase + string.ascii_uppercase + "1234567890-=!@#$%^&*()_+`~,.<>/?" 

# This function tests the password given to it by the recursiveTest function.
def testPassword(password):
    # flag global variables as global, otherwise it'll get upset that they aren't defined as local variables when you try use them
    global isCracked
    global pwAttempts

    # If the password has not been cracked, test it against the known hash (targetPasswordHash)
    if not isCracked:
        # Calculate the hash value of the generated string
        tmpHash = hashlib.sha256(password.encode("utf-8")).hexdigest()
        # Keep count of how many attempts it took to calculate the password, for fun.
        pwAttempts = pwAttempts + 1
        # Display out to the user what string is being tested, and the attempt number
        print("password: ", password, "\t | attempt number: ", pwAttempts)
        # Test if the hashes match
        if tmpHash == targetPasswordHash:
            # Notify the user that the passwords match
            print("Password has been cracked! It was",'\033[1m\033[92m',password,'\033[0m',"and required", pwAttempts, "attempts to crack!")
            # Set the global isCracked variable to True, to stop the testing, as it has found the password. 
            # If this is not set, then the script will keep running until the full set of defined lengths is exhausted, 
            # OR, the system runs out of memory, OR, runs into the recursion limit!
            isCracked = True

# This function tests every permutation of characters within a defined character length limit (defined by tmplength).
# This function calls itself with a new string to test
# This does spawn an awful lot of function calls, however is required due to the three-dimensional aspect of password testing
def recursiveTest(tmpstring, tmplength):    
    # Make sure the temporary string length is not beyond the requested length of the password, otherwise it'll run away!
    if len(tmpstring) > tmplength:
        return

    # For each character in the list of possible characters
    for char in possiblechars:
        # Add a character onto the string. This character will be each character in the allowed character string!
        temp = tmpstring + char
        # Test this combination of the previous attempted password, and the new character
        testPassword(temp)
        # Re-run the recursiveTest function with this new temp string
        recursiveTest(temp, tmplength)

# Calls the recursiveTest function with the requested length set to that of the range function's output
# range essentially turns an array of numbers from 1 to the specified number. For example: range(3) turns into [1,2,3]
for n in range(3):
    # If the password has not been cracked
    if not isCracked:
        # Call recursiveTest with an empty password string, and the length as defined by whichever number the for loop is at, defined by 'n'
        recursiveTest("", n)