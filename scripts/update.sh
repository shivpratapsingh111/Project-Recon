#!/bin/bash

current_dir=$(basename "$PWD")

if [ "$current_dir" == "Project-Recon" ]; then
    git clone https://github.com/shivpratapsingh111/Project-Recon.git
    
    rsync -av --exclude='main.py' --exclude='.git' --exclude='scripts' --exclude='Backup' --exclude='readme.md' ./ Project-Recon
    mv Project-Recon ../temp
    cd ../
    rm -rf Project-Recon
    mv temp Project-Recon
    cd Project-Recon
    rm -rf Project-Recon

else
    echo "The current directory is not named 'Project-recon'."
fi
