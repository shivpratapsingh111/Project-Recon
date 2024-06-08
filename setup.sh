#!/bin/bash


allTools=("assetfinder" "subfinder" "amass" "subdominator" "haktrails" "waymore" "katana" "gau" "waybackurls" "nuclei" "kxss" "qsreplace" "dirsearch" "httpx" "dnsgen" "altdns" "alterx" "puredns")

commonUtilties=("python3" "pip3" "sed" "gawk" "coreutils" "curl" "git")

missingTools=()
missingAgain=()
packetManager=""
allPresent=0

mkdir -p ~/tools




installmissingTools(){

    for tool in ${missingTools[@]}; do
        
        case $tool in

        # Subdomain gathering tools
            "amass")
                /usr/local/go/bin/go install -v github.com/owasp-amass/amass/v4/...@master
                ;;
            "assetfinder")
                /usr/local/go/bin/go install -v github.com/tomnomnom/assetfinder@latest
                ;;
            "haktrails")
                /usr/local/go/bin/go install -v github.com/hakluke/haktrails@latest
                ;;
            "subdominator")
                pip3 install git+https://github.com/RevoltSecurities/Subdominator
                ;;
            "subfinder")
                /usr/local/go/bin/go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
                ;;
            "dnsgen")
                python -m pip install dnsgen
                ;;
            "altdns")
                pip3 install "py-altdns==1.0.2"
                ;;
            "alterx")
                go install github.com/projectdiscovery/alterx/cmd/alterx@latest
                ;;
            "puredns")
                go install github.com/d3mondev/puredns/v2@latest
                ;;


        # URL gathering tools
            "gau")
                /usr/local/go/bin/go install -v github.com/lc/gau/v2/cmd/gau@latest
                ;;
            "katana")
                /usr/local/go/bin/go install -v github.com/projectdiscovery/katana/cmd/katana@latest 
                ;;
            "waybackurls")
                /usr/local/go/bin/go install -v github.com/tomnomnom/waybackurls@latest
                ;;
            "waymore")
                pip3 install git+https://github.com/xnl-h4ck3r/waymore.git -v
                ;;



        # Misc Tools
            "dirsearch")
                pip3 install dirsearch
                ;;
            "kxss")
                /usr/local/go/bin/go install -v github.com/Emoe/kxss@latest
                ;;
            "nuclei")
                /usr/local/go/bin/go install -v github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest
                ;;
            "qsreplace")
                /usr/local/go/bin/go install -v github.com/tomnomnom/qsreplace@latest
                ;;
            "httpx")
                /usr/local/go/bin/go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest
                ;;
            *)
                echo "[+] Installation method not added for: $tool"
                ;;
        esac
    done

    if [ $(ls ~/go/bin | wc -l) -gt 0 ]; then
        sudo mv ~/go/bin/* /usr/bin/
    fi
}





fixMissingAgain(){
    for tool in ${missingAgain[@]}; do
        echo "[+] Fixing misses"
        echo "y" | sudo pip3 uninstall $tool
        echo "[+] Fixed misses"
    done

    installmissingTools
}





checkTools(){
# Checking for missing tools

    for tool in "${allTools[@]}"; do
    
        if ! command -v $tool &>/dev/null; then
            missingTools+=("$tool")
            
        fi
    done
    
    if [ ${#missingTools[@]} -gt 0 ]; then
        echo "[+] Following tools are missing: "
        echo "---"
        for tool in ${missingTools[@]}; do
            echo "- ""$tool"
        done
        echo "---"
        echo ""
        installmissingTools

    fi


# Checking and fixing errors for still missing tools (that may not got installed due to some errors)
    for tool in "${allTools[@]}"; do
    
        if ! command -v $tool &>/dev/null; then
            missingAgain+="$tool"
        fi
    done

    if [ ${#missingAgain[@]} -gt 0 ]; then
        fixMissingAgain
    fi


# Checking if all tools are installed
    for tool in "${allTools[@]}"; do
    
        if ! command -v $tool &>/dev/null; then
            allPresent+=1
        fi
    done

    if [ $allPresent -gt 0 ]; then
        continue
    else
        echo "[+] All required tools are installed"
        echo "[+] Set API Keys in config file for waymore & subfinder"
    fi

# Printing name of tools, that were unable to install
    for tool in "${allTools[@]}"; do
    
        if ! command -v $tool &>/dev/null; then
            echo "[+] Not Installed, Install manually $tool"
            
        fi
    done

}




updateUpgrade() {

    if [ -f /etc/debian_version ]; then

        echo "[+] OS: Debian"
        
        echo "y" | sudo apt update
        echo "y" | sudo apt full-upgrade -y
        echo "y" | sudo apt autoremove -y

        for utility in ${commonUtilties[@]}; do

            if [ $utility == "coreutils" ]; then

                if ! command -v cut &>/dev/null; then

                    echo "[+] $utility not present, Installing..."
                    echo "y" | sudo apt install coreutils

                fi

            elif ! command -v $utility &>/dev/null; then

                echo "[+] $utility not present, Installing..."
                echo "y" | sudo apt install $utility

            fi
            
        done      


    elif [ -f /etc/fedora-release ]; then

        echo "[+] OS: Fedora"

        echo "y" | sudo dnf update -y
        echo "y" | sudo dnf clean all

        for utility in ${commonUtilties[@]}; do

            if [ $utility == "coreutils" ]; then

                if ! command -v cut &>/dev/null; then

                    echo "[+] $utility not present, Installing..."
                    echo "y" | sudo dnf install coreutils

                fi

            elif ! command -v $utility &>/dev/null; then

                echo "[+] $utility not present, Installing..."
                echo "y" | sudo dnf install $utility

            fi

        done      


    elif [ -f /etc/arch-release ]; then

        echo "[+] OS: Arch"

        echo "y" | sudo pacman -Syu

        for utility in ${commonUtilties[@]}; do

            if [ $utility == "coreutils" ]; then

                if ! command -v cut &>/dev/null; then

                    echo "[+] $utility not present, Installing..."
                    echo "y" | pacman -S coreutils

                fi

            elif ! command -v $utility &>/dev/null; then

                echo "[+] $utility not present, Installing..."
                echo "y" | pacman -S $utility

            fi
            
        done               

    fi

    
# Checking & Installing Go Lang

    if ! command -v /usr/local/go/bin/go &> /dev/null; then
        echo "Go is not installed. Installing..."
        curl https://go.dev/dl/go1.22.3.linux-amd64.tar.gz -L --output go1.22.3.linux-amd64.tar.gz &
        wait
        sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf go1.22.3.linux-amd64.tar.gz & 
        wait
        export PATH=$PATH:/usr/local/go/bin
    fi

}




# Driver Code
mainFunction(){
if [ "$EUID" -ne 0 ]
  then echo "Please run $0 as root"
  exit
fi

updateUpgrade
checkTools
}


# Calling mainFunction
mainFunction


