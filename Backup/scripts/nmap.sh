#!/bin/bash

domainFile=$1

# ---

GREEN=$(tput setaf 2)
RED=$(tput setaf 1)
ORANGE=$(tput setaf 3)
RESET=$(tput sgr0) 

timeDate=$(echo -e "${ORANGE}[$(date "+%H:%M:%S : %D")]\n${RESET}")
time=$(echo -e "${ORANGE}[$(date "+%H:%M:%S")]\n${RESET}")

# Function to calculate visible length of the message (excluding color codes)
calculate_visible_length() {
  local message=$1
  # Remove color codes
  local clean_message=$(echo -e "$message" | sed 's/\x1b\[[0-9;]*m//g')
  echo ${#clean_message}
}

# Function to print the message with aligned time
print_message() {
  local color=$1
  local message=$2
  local count=$3
  local time=$(date +"%H:%M:%S")

  if [ -n "$count" ]; then
    formatted_message=$(printf '%s[%s%d] %s' "$color" "$message" "$count" "$RESET")
  else
    formatted_message=$(printf '%s[%s] %s' "$color" "$message" "$RESET")
  fi

  visible_length=$(calculate_visible_length "$formatted_message")
  total_length=80
  spaces=$((total_length - visible_length))
  
  printf '\t\t|---%s%*s[%s]\n' "$formatted_message" "$spaces" " " "$time"
}

# ---

getASN() {
# Find Ip Rnages from ASN
while IFS= read -r domain; do 

    dir="results/$domain"
    cd $dir

    # Message main
    printf '\t%s[%s]%s\t%s' "$ORANGE" "$domain" "$RESET" "$timeDate"

# Getting ASN
    # Message
    print_message "$GREEN" "Gathering ASN"

    # Calling python file responsible of rgetting ASN
    python3 $baseDir/scripts/getAsn.py $domain 1> /dev/null
    sort -u asn.txt -o asn.txt 2> /dev/null 1> /dev/null

    # Message
    print_message "$GREEN" "ASN found "$(cat 'asn.txt' 2> /dev/null | wc -l)""


# Extracting IP Ranges, if any ASN found
    if ! [ $(wc -l < "asn.txt") -eq 0 ]; then

        # Message
        print_message "$GREEN" "Extracting IP ranges for $domain"

        while IFS= read -r ASN; do
            whois -h whois.radb.net -- '-i origin' "$ASN" | grep -Eo "([0-9.]+){4}/[0-9]+" | uniq  | tee -a ipRanges.txt 1> /dev/null
        done < "asn.txt"
        sort -u ipRanges.txt -o ipRanges.txt 2> /dev/null 1> /dev/null

        # Message
        print_message "$GREEN" "IP ranges found "$(cat ipRanges.txt 2> /dev/null | wc -l)""

    fi

# Getting IPs of found subdomains
    # Message
    print_message "$GREEN" "Extracting IPs from subdomains $domain"
    while IFS= read -r subdomain; do

        dig +short "$subdomain" 2> /dev/null 1> subdomainIps.txt

    done < ".tmp/subdomains/active+passive.txt"
    # Message
    print_message "$GREEN" "IPs found "$(cat subdomainIps.txt 2> /dev/null | wc -l)""


# Scan through nmap    
    if ! [ $(wc -l < "ipRanges.txt") -eq 0 ]; then

        # Message
        print_message "$GREEN" "Nmap scan started"

    # Calling NMAP
        python3 $baseDir/scripts/nmap.py $domainFile 1> /dev/null

    fi
    
  mkdir -p network
  mv ipRanges.txt subdomainIps.txt asn.txt network 2> /dev/null
    # Go back to Project-Recon dir at last 
    cd $baseDir

done < $domainFile

}


# Call of Nmap ;)
getASN

