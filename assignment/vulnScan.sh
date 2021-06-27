#!/bin/bash

# NOTE: This script requires the 'jq' package installed in order to run correctly

# workspace folder
dirWorkspace="./.workspace"

#json download URL - used for grabbing the json data from NIST
jsonGzURL="https://nvd.nist.gov/feeds/json/cve/1.1/nvdcve-1.1-recent.json.gz"

#names of json data files - the gzip file, the extracted json file, and the processed data txt file
fileJsonGzName="recent-json.gz"
fileJsonJsonName="recent-json.json"
fileJsonParsedDataName="jsonParsedData.txt"

# json parsed data delimiter - character used to signify the end of each field
fileDataDelimiter='~'

# The file used for searched content. This is a because of bash's limitations of passing arrays as variables and the like
fileSearchResults=searchdata.txt

# Colour codes
colRed="\x1b[31m"
colYellow="\x1b[33m"
colGreen="\x1b[32m"
colBlack="\x1b[30m"
colRedBG="\x1b[41m"
colReset="\x1b[0m"

# Called when needing to display information
# e.g. displayInfo "File has been found"
displayInfo()
{
    echo -e "$colGreen INFO: $* $colReset"
}

# Called when needing to display errors
# e.g. displayError "Cannot find file!"
displayError()
{
    echo -e "$colRed ERROR: $* $colReset"
}

# Checks if there is a workspace folder, otherwise it creates it
checkWorkspace()
{
    # If the defined workstation folder does not exist, then create it
    if [[ ! -d $dirWorkspace ]]; then
        displayInfo "Creating working directory"
        mkdir $dirWorkspace
    fi
    # TODO make it check for the created folder again, and if it's not there, error with an exit code
}

# Checks the stored JSON file, and if it's too old or does not exist, it'll download a new one via updateJSON()
checkJSON()
{
    displayInfo "Checking for existing pre-processed data file"
    
    # If the processed JSON data does not exist, download the json from NIST and import it
    if [[ ! -f "$dirWorkspace/$fileJsonParsedDataName" ]]; then
        displayInfo "Existing pre-processed data file not found"
        updateJSON
        return
    else
        # else import the pre-processed data
        importPreProcessedData
    fi

    # Check if the processed JSON data is recent (less than a few days old)
    # TODO
    # else update it
}

importPreProcessedData()
{
    displayInfo "Importing pre-processed JSON data. Please wait..."
    # Read each line of the preprocessed json data
    while read line; do
        local tmpLineArray

        # Grabs each line and splits it using the data delimiter character
        readarray -d "$fileDataDelimiter" -t tmpLineArray <<< $line

        # Each field is added to it's respective array
        jsonID+=(${tmpLineArray[0]})
        #echo ${tmpLineArray[0]}
        jsonScore+=(${tmpLineArray[1]})
        #echo ${tmpLineArray[1]}
        jsonDesc+=(${tmpLineArray[2]})
        #echo ${tmpLineArray[2]}
    done < $dirWorkspace/$fileJsonParsedDataName
}

updateJSON()
{
    displayInfo "Fetching NIST NVD JSON"

    # Remove old JSON data
    # if the gzip file exists, delete it
    if [[ -f "$dirWorkspace/$fileJsonGzName" ]]; then
        rm $dirWorkspace/$fileJsonGzName
    fi
    # if the extracted json file exists, delete it
    if [[ -f "$dirWorkspace/$fileJsonJsonName" ]]; then
        rm $dirWorkspace/$fileJsonJsonName
    fi
    
    # Downloads and extracts the NIST recent vulnerabilities JSON into the workspace
    wget -O "$dirWorkspace/$fileJsonGzName" $jsonGzURL  >>/dev/null 2>&1;

    # For some reason, wget exits with code 4, which is a network error, thus I cannot test if it succeeds directly
    # Thus I opt to test if the file has been created and go from there.

    if [ ! -s $dirWorkspace/$fileJsonGzName ]; then
        displayError "Could not retrive JSON data from NIST!"
        exitScript "" 1 # Could not download JSON data
    fi

    # Extract the json information | -d: decompress | -k: keep | -c: cats the file contents out, which in this case is shoved into a .json file
    gzip -dkc "$dirWorkspace/$fileJsonGzName" > "$dirWorkspace/$fileJsonJsonName"

    # Process JSON to be usable information
    processJSON
}

# Processes the information found in the json file into arrays for reading/displaying
processJSON()
{
    displayInfo "Processing JSON information ... Please wait"

    # Grab vulnerabilities and put into an object
    echo "jsonItems"
    jsonItems=$(cat $dirWorkspace/$fileJsonJsonName | jq '."CVE_Items" | keys | .[]')
    
    echo "jsonParse"
    # Sort all items into parallel arrays
    # CVE ID, score, breif description
    for index in $jsonItems;
    do
        # Initialise tmp variables
        local tmpScore
        local tmpID
        local tmpDesc
        
        # Grab the CVE score - Ignoring anything that has a null score. This must be done first as not to waste time processing data that would otherwise be thrown out
        tmpScore=$(cat $dirWorkspace/$fileJsonJsonName | jq ".CVE_Items[${index}].impact.baseMetricV3.cvssV3.baseScore")
        
        # 'null' records are returned as literal strings of 'null'. We shall skip any loop that has a score of 'null'
        if [ $tmpScore == 'null' ];
        then
            continue
        fi

        # Get CVE ID
        tmpID=$(cat $dirWorkspace/$fileJsonJsonName | jq ".CVE_Items["${index}"].cve.CVE_data_meta.ID" | sed 's/"//g') # sed replaces all " characters with nothing

        # Get CVE Description
        tmpDesc=$(cat $dirWorkspace/$fileJsonJsonName | jq -r ".CVE_Items[${index}].cve.description.description_data | .[].value")

        # Store the data taken from this entry in the JSON as strings in parallel arrays
        jsonID+=("$tmpID")
        jsonScore+=("$tmpScore")
        jsonDesc+=("$tmpDesc")
        
        # Write out the processed JSON data into a text file that can be used upon restart of the application
        printf '%s%s%s%s%s\n' "$tmpID" "$fileDataDelimiter" "$tmpScore" "$fileDataDelimiter" "$tmpDesc" >> $dirWorkspace/$fileJsonParsedDataName
        
    done
    displayInfo "JSON processing complete!"
    #echo $jsonItems
    #echo $jsonID
    #echo $jsonScore
}




searchMenu()
{
    # Clears the terminal the script is being run in, to make it appear more presentable
    clear
    # Loop infinitely, until exited or returned
    while true 
    do
        local menuOption
        echo -e "Search:"
        echo -e "1) Enter a search term"
        echo -e "2) Exit back to main menu"

        read menuOption
        clear
        case $menuOption in
            1)
                local searchterm

                echo -e "Please enter a searchterm and press Enter:"
                # Search by keyword
                read searchterm

                displaySearchResults $dirWorkspace/$fileJsonParsedDataName $searchterm
            ;;
            2)
                # Exit back to main menu and clear terminal
                clear
                return
            ;;
            *)
                # error on incorrect entry
                displayError "Incorrect menu option selected, please try again"
            ;;
        esac
    done
}

# Used to terminate the script. Can be used for any exit conditions as it accepts an exit message and exit code.
# e.g. exitScript "Goodbye!" 0
exitScript()
{
    # Output exit message
    echo -e $1
    # exit with relevant exit code
    exit $2
}

# Prints an ASCII art banner - Note: content cannot be indented else it will be printed indented.
printMOTD()
{
    echo -e "
██╗   ██╗██╗   ██╗██╗     ███╗   ██╗    ███████╗███████╗ █████╗ ██████╗  ██████╗██╗  ██╗
██║   ██║██║   ██║██║     ████╗  ██║    ██╔════╝██╔════╝██╔══██╗██╔══██╗██╔════╝██║  ██║
██║   ██║██║   ██║██║     ██╔██╗ ██║    ███████╗█████╗  ███████║██████╔╝██║     ███████║
╚██╗ ██╔╝██║   ██║██║     ██║╚██╗██║    ╚════██║██╔══╝  ██╔══██║██╔══██╗██║     ██╔══██║
 ╚████╔╝ ╚██████╔╝███████╗██║ ╚████║    ███████║███████╗██║  ██║██║  ██║╚██████╗██║  ██║
  ╚═══╝   ╚═════╝ ╚══════╝╚═╝  ╚═══╝    ╚══════╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝
"
}

# Displays CVE entries that are passed to it
# e.g. displayCVE $dirWorkspace/$fileJsonParsedDataName
displayCVE()
{
    # Clears the terminal the script is being run in, to make it appear more presentable
    clear
    
    # Displays the entire contents of json data
    awk -F$fileDataDelimiter 'BEGIN{
        print("Displaying all recent CVE vulnerabilities:\n")
    }

    {
        printf("\x1b[1mCVE ID: %-15s\x1b[0m\nScore: %-4s\nDescription:\n%-30s\n", $1, $2, $3)
        printf("%s", "_______________________________\n")
    }
    ' "${1}"  | sed -E -e "s/Score: [0-3].[0-9]/$colGreen&$colReset/g" | # Low CVE scores are coloured green
    sed -E -e "s/Score: [4-7].[0-9]/$colYellow&$colReset/g" | # Medium CVE scores are coloured yellow
    sed -E -e "s/Score: [8-9].[0-9]/$colRed&$colReset/g" | # High CVE scores are coloured red foreground
    sed -E -e "s/Score: 10.[0-9]/$colBlack$colRedBG&$colReset/g" |# Max CVE scores are coloured red background and black foreground
    less -r
}

# A separate display function very similar to the other, but formatted differently as passing variables as files vs variables behaves differently.
# Also passing the dataset back and forth between functions also causes it to break, thus, two functions were required.
displaySearchResults()
{
    # Clears the terminal the script is being run in, to make it appear more presentable
    clear
    #echo "displayCVE" >&2
    local dataSource=$1
    local searchstr=$2
    
    cat $dataSource | # Reads out the data to be displayed
    grep -P $searchstr | # Filters down the data to only show information containing the input search term
    sed -e "s/$searchstr/$colGreen$searchstr$colReset/g" | # Add green highlighting to the found search terms, and then passes it on to awk to display
    awk -F$fileDataDelimiter 'BEGIN{
        print("Displaying all CVE vulnerabilities containing your chosen search term:\n")
    }

    {
        printf("\x1b[1mCVE ID: %-15s\x1b[0m\nScore: %-4s\nDescription:\n%-30s\n", $1, $2, $3)
        printf("%s", "_______________________________\n")
    }
    ' | sed -E -e "s/Score: [0-3].[0-9]/$colGreen&$colReset/g" | # Low CVE scores are coloured green
    sed -E -e "s/Score: [4-7].[0-9]/$colYellow&$colReset/g" | # Medium CVE scores are coloured yellow
    sed -E -e "s/Score: [8-9].[0-9]/$colRed&$colReset/g" | # High CVE scores are coloured red foreground
    sed -E -e "s/Score: 10.[0-9]/$colBlack$colRedBG&$colReset/g" |# Max CVE scores are coloured red background and black foreground
    less -r
}

mainMenu()
{
    local menuOption
    # Clears the terminal the script is being run in, to make it appear more presentable
    clear

    
    # Loop infinitely, until exited or returned
    while true
    do
    # Prints the script banner ASCII art
    printMOTD
        # Menu asks if you want to view all CVEs, search, or exit
        echo -e "Please select an option:
        1. View all recent CVEs
        2. Search
        3. Exit"
        
        read menuOption

        case $menuOption in
                1)
                    #View all CVEs
                    displayCVE $dirWorkspace/$fileJsonParsedDataName
                    #displayCVE $dirWorkspace/$fileJsonParsedDataName
                ;;
                2)
                    # Search
                    searchMenu
                ;;
                3)
                    # Exit
                    exitScript "Goodbye!" 0
                ;;
                *)
                    displayError "Invalid selection! Please try again"
                ;;
        esac
    done
}


##### MAIN #####

# Check if workspace folder is created
checkWorkspace

# Get latest NIST CVE json "recent"
checkJSON

# Show menu
mainMenu
