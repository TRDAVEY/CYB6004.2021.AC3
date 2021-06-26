#!/bin/bash

# NOTE: This script requires the 'jq' package installed in order to run correctly

# workspace folder
dirWorkspace="./.workspace"

#json download URL
jsonGzURL="https://nvd.nist.gov/feeds/json/cve/1.1/nvdcve-1.1-recent.json.gz"

#json file name
fileJsonGzName="recent-json.gz"
fileJsonJsonName="recent-json.json"

#Data arrays - Holds the parsed json data - TODO - determine if these are required?
#jsonItems=() # index ID for each CVE entry
#jsonID=() # CVE ID (CVE-2020-18661)
#jsonVendor[] # Affected vendor - e.g. NVIDIA
#jsonScore=() # Vulnerability score - e.g. 9.8 - Uses v3 scores as there will be no legacy scores in new vulnerabilities


# Called when needing to display information
displayInfo()
{
    echo -e "\033[32mINFO: $*\033[0m"
}

# Called when needing to display errors
displayError()
{
    echo -e "\033[31mERROR: $*\033[0m"
}

checkWorkspace()
{
    # If the defined workstation folder does not exist, then create it
    if [[ ! -d $dirWorkspace ]]; then
        displayInfo "Creating working directory"
        mkdir $dirWorkspace
    fi
}

# Checks the stored JSON file, and if it's too old, it'll download a new one via updateJSON()
checkJSON()
{
    #
    echo "checkJSON"

    # Check if the JSON file exists
    if [[ ! -f "$dirWorkspace/$fileJsonJsonName" ]]; then
        updateJSON
        return
    fi
}

updateJSON()
{
    echo "updateJSON"
    displayInfo "Updating NIST NVD JSON"
    # Remove old JSON data
    if [[ -f "$dirWorkspace/$fileJsonGzName" ]]; then
        rm $dirWorkspace/$fileJsonGzName
    fi
    if [[ -f "$dirWorkspace/$fileJsonJsonName" ]]; then
        rm $dirWorkspace/$fileJsonJsonName
    fi
    
    # Downloads and extracts the NIST recent vulnerabilities JSON into the workspace
    wget -O "$dirWorkspace/$fileJsonGzName" $jsonGzURL  >>/dev/null 2>&1;

    # For some reason, wget exits with code 4, which is a network error, thus I cannot test if it succeeds directly
    # Thus I opt to test if the file has been created and go from there.

    if [ ! -s $dirWorkspace/$fileJsonGzName ]; then
        displayError "Could not retrive JSON data from NIST!"
        exit 1 # Could not download JSON data
    fi

    # Extract the json information | -d: decompress | -k: keep | -c: cats the file contents out, which in this case is shoved into a .json file
    gzip -dkc "$dirWorkspace/$fileJsonGzName" > "$dirWorkspace/$fileJsonJsonName"
}

# Processes the information found in the json file into arrays for reading/displaying
processJSON()
{
    # 
    echo "processJSON"
    displayInfo "Processing JSON information ... Please wait"

    # Grab vulnerabilities and put into an object
    echo "jsonitems"
    jsonItems=$(cat $dirWorkspace/$fileJsonJsonName | jq '."CVE_Items" | keys | .[]')
    #echo $jsonItems
    echo "jsonParse"
    # Sort all items into parallel arrays
    # CVE ID, score, breif description
    for index in $jsonItems;
    do
        # Grab the score - Ignoring anything that has a null score. This msut be done first as not to waste time processing data that would otherwise be thrown out
        tmpScore=$(cat $dirWorkspace/$fileJsonJsonName | jq ".CVE_Items[${index}].impact.baseMetricV3.cvssV3.baseScore")
        
        # 'null' records are returned as literal strings of 'null', this we shall skip any loop that has a score of 'null'
        if [ $tmpScore == 'null' ];
        then
            continue
        fi
        # Get CVE ID
        tmpID=$(cat $dirWorkspace/$fileJsonJsonName | jq ".CVE_Items["${index}"].cve.CVE_data_meta.ID")

        # Get CVE Description
        tmpDesc=$(cat $dirWorkspace/$fileJsonJsonName | jq -r ".CVE_Items[${index}].cve.description.description_data | .[].value")
        jsonID+="$tmpID"
        jsonScore+="$tmpScore"
        jsonDesc+="$tmpDesc"
        
        
    done
    echo "END OF PROCESS"
    #echo $jsonItems
    #echo $jsonID
    #echo $jsonScore

    # Export information into text file for caching + ease of use during future runs
}




##### MAIN #####

# Check if workspace folder is created
checkWorkspace

# Get latest nist CVE json "recent"
checkJSON

# Process JSON to be usable information
processJSON

# Show menu
# Menu asks if you want to search, or view all CVEs
# Search by CVE (strip out CVE- with sed and search only with year-number (2021-32568))
# Search by keywords in description (regex)
# Search by vulnerability scores greater than value input