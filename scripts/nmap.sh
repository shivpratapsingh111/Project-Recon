#!/bin/bash

asn=$1

# Find IPs from ASN
while IFS= read -r ASN; do
    whois -h whois.radb.net -- '-i origin' "$ASN" | grep -Eo "([0-9.]+){4}/[0-9]+" | uniq  | tee ipRanges.txt
done

# Running nmap for all ip ranges

for ipRange in $(cat "ipRanges.txt"); do
    nnmap -v --host-timeout=28800s -Pn -T4 -sT -sV --max-retries=1 --open $ipRange --script=default -p 0-1024,10000,1010,10250,10443,1099,11371,12043,12046,12443,1311,15672,16080,17778,18091,18092,20720,2082,2087,2095,2096,21,22,2480,280,28017,300,3000,3128,32000,3333,3389,4243,443,4444,4445,4567,4711,4712,4993,5000,5001,5104,5108,5280,5281,55440,55672,5601,5800,583,591,593,6543,7000,7001,7002,7396,7474,80,8000,8001,8008,8009,8014,8042,8060,8069,8080,8081,8083,8088,8090,8091,8095,81,8118,8123,8172,8181,8222,8243,8280,8281,832,8333,8337,8443,8500,8530,8531,8800,8834,8880,8887,8888,8983,9000,9001,9043,9060,9080,9090,9091,9092,9200,9443,9502,9800,981,9981 -oG nmapGrepableOuput_$ipRange.txt
done