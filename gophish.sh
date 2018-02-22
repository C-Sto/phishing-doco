#!/bin/bash

RED="\033[01;31m"      # Issues/Errors
GREEN="\033[01;32m"    # Success
YELLOW="\033[01;33m"   # Warnings/Information
BLUE="\033[01;34m"     # Heading
BOLD="\033[01;01m"     # Highlight
RESET="\033[00m"       # Normal

if [ -z $1 ] ; then
    echo Usage: $(which bash) gophish.sh domain
    echo Where domain is the domain-name pointing to the current box. Specify multiple by separating them with a space.
    exit
fi

# Update and upgrade
echo -e "${GREEN}[+]${RESET} Updating your computey"
apt-get update >> ~/gophish.log
apt-get -y upgrade >> ~/gophish.log

# Installing golang
echo -e "${GREEN}[+]${RESET} Installing golang"
apt-get -y install golang-1.9-go >> ~/gophish.log
echo "export PATH=$PATH:/usr/lib/go-1.9/bin" >> ~/.bashrc
export PATH=$PATH:/usr/lib/go-1.9/bin

# Installing python
echo -e "${GREEN}[+]${RESET} Installing python"
apt-get -y install python >> ~/gophish.log

# Installing certbot
echo -e "${GREEN}[+]${RESET} Installing certbot"
apt-get -y install letsencrypt >> ~/gophish.log

# Get username and home dir
user=$(whoami)
home=~

# Set up go environment
echo -e "${GREEN}[+]${RESET} Setting up your go environment"
mkdir ~/golang
echo export GOPATH=\"$home/golang\" >> ~/.bashrc
echo export PATH=\"\$GOPATH:\$PATH\" >> ~/.bashrc
source ~/.bashrc

# sleep because it fixes the problem
sleep 5

# Get/build gophish
echo -e "${GREEN}[+]${RESET} Installing gophish"
go get github.com/gophish/gophish >> ~/gophish.log
cd $GOPATH/src/github.com/gophish/gophish
go build >> ~/gophish.log

sleep 1

# Change config
echo -e "${GREEN}[+]${RESET} Modifying config.json for external accessibility over 443"
sed -i 's/127.0.0.1/0.0.0.0/g' $GOPATH/src/github.com/gophish/gophish/config.json
sed -i 's/80/443/g' $GOPATH/src/github.com/gophish/gophish/config.json
sed -i 's/false/true/g' $GOPATH/src/github.com/gophish/gophish/config.json

#  cert stuff
echo -e "${GREEN}[+]${RESET} Modifying cert entries on config.json"
sed -i 's/gophish_admin.crt/cert.pem/g' $GOPATH/src/github.com/gophish/gophish/config.json
sed -i 's/example.crt/cert.pem/g' $GOPATH/src/github.com/gophish/gophish/config.json
sed -i 's/gophish_admin.key/privkey.pem/g' $GOPATH/src/github.com/gophish/gophish/config.json
sed -i 's/example.key/privkey.pem/g' $GOPATH/src/github.com/gophish/gophish/config.json

echo -e "${GREEN}[+]${RESET} Generating certificates"
# do the thing
DOMAINZ=$(echo $@ | sed -e "s/\ /\ -d\ /g")
letsencrypt certonly --standalone --register-unsafely-without-email --agree-tos -d $DOMAINZ

echo -e "${GREEN}[+]${RESET} Linking certs"
echo 'Linking certificates'
ln -s /etc/letsencrypt/live/$1/cert.pem $GOPATH/src/github.com/gophish/gophish/cert.pem
ln -s /etc/letsencrypt/live/$1/privkey.pem $GOPATH/src/github.com/gophish/gophish/privkey.pem


cd $GOPATH/src/github.com/gophish/gophish
nohup ./gophish &
sleep 3
cd

echo -e "${GREEN}[+]${RESET} Done!"
echo The Gophish binary can be found at $GOPATH/src/github.com/gophish/gophish/
echo 'I tried to run it. It may be running?'
echo
echo -e "${YELLOW}[!]${RESET} This isn't bulletproof. Your installation may not work."
