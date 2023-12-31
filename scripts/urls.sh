#!/bin/bash

read domain
dir=$(head -1 $domain)
cd $dir || exit 1
rm urls.txt 2> /dev/null

(
    cat subdomains.txt | waybackurls > wayback_urls.txt 
) &

# (
#     rm para.txt 2> /dev/null
#     file="live_subdomains.txt"
#     while read -r line; do
#     python3 ~/tools/ParamSpider/paramspider.py -d $line 2> /dev/null | grep -E "https?://\S+" >> paramspider.txt
#     done < $file
#     rm -rf output/
# ) &

(
    cat subdomains.txt | gau > gau_urls.txt 
) &

(
    cat subdomains.txt | katana scan --depth 3 > katana_urls.txt 2> /dev/null
) &

(
    mkdir ~/tools/waymore/old_results 2> /dev/null
    mv ~/tools/waymore/results/* ~/tools/waymore/old_results/
    sed 's/^https\?:\/\/\(www\.\)\?//' subdomains.txt > for_waymore.txt
    python3 ~/tools/waymore/waymore.py -i for_waymore.txt -mode U
) &
wait


cat ~/tools/waymore/results/*/waymore.txt | sort -u > waymore_urls.txt

cat wayback_urls.txt gau_urls.txt katana_urls.txt waymore_urls.txt | sort -u > urls.txt 2> /dev/null &

wait

cat urls.txt | grep -F .js | cut -d "?" -f 1 | sort -u | tee jsUrls.txt 1> /dev/null 

#-------------------------------------URLs_Done------------------------------------------------


rm wayback_urls.txt gau_urls.txt katana_urls.txt waymore_urls.txt for_waymore.txt

cd ../
#-----------------------------------------Organizing_Done---------------------------------------


