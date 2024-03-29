#!/bin/bash

domain=$1
link=$2

# For getting firdst 20 charachters of $link so we can grep for it to get proper open redirects.
first_20="${link:0:20}"

dir=$(head -1 $domain)

cd "$dir" || exit 1
rm openRedirects.txt 2> /dev/null
rm ssrfUrls.txt 2> /dev/null
file="urls.txt"

counter=1

while read -r line; do
  lc=$link?no=$counter
  qs=$(echo "$line" | grep = | qsreplace -a | qsreplace $lc | awk NF |sort -u | tee -a ssrfUrls.txt)  # Use the counter in the query
  headers=$(curl -I -L "$qs" -k 2> /dev/null)
  location_header=$(echo "$headers" | grep -i "location:" 2> /dev/null)
  if [ -n "$location_header" ]; then
    url=$(echo "$location_header" | awk '{print $2}')
    echo "$qs ---> $url" >> openredirectUrls.txt
  fi

  counter=$((counter+1))
done < "$file"

# Filtering out proper Open Redirects
cat openredirectUrls.txt | grep -- "---> $first_20" > openRedirects.txt

rm openredirectUrls.txt

cd ../