# from subprocess import Popen
# commands = ['python3 rec2.py', 'python3 recursion.py']
# procs = [ Popen(i) for i in commands ]
# for p in procs:
#    p.wait()

# -------------------------------------------------------------------------------------

import subprocess
import os

domain = input("Enter the domain name: ")

def subdomains():
    print("[Task: subdomainEnumeration] [Status: Running]")
    p_subdomain = subprocess.run(f'echo {domain} | ./subdomains.sh',shell=True)

def subTakeover():
    p_urls= subprocess.Popen(f'echo {domain} | ./subTakeover.sh',shell=True)


def urls():
    print("[Task: url] [Status: Running]")
    p_urls= subprocess.Popen(f'echo {domain} | ./urls.sh',shell=True)


if __name__ == '__main__':
    os.system('clear')
    print("[Status: Running]")
    subdomains()
    subTakeover()
    urls()
