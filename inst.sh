#!/bin/bash

# =============================================================================
#               Rocket.Chat installer for (Ubunutu)
# =============================================================================
#   By:     Cameron Munroe ~ Mun
#   Ver:    0.0
#   
#
#
#
#
#
#
# =============================================================================

# Getting newest apt-cache.
apt-get update
wait

# Let's do a quick upgrade.
apt-get dist-upgrade -y
wait

# Let's add MongoDB Repo.
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10
wait
echo "deb http://repo.mongodb.org/apt/ubuntu trusty/mongodb-org/3.0 multiverse" >> /etc/apt/sources.list.d/mongodb-org-3.0.list

# Install Monogodb depends.
apt-get install mongodb-org curl graphicsmagick -y
wait

# Install NodeJS and depends.
apt-get install nodejs -y
wait
apt-get install npm -y
wait
apt-get install build-essential -y
wait

# Change NodeJS version
npm install -g n
wait
n 4.5
wait

# Configure MongoDB.
echo 'replication:' >> /etc/mongod.conf
echo '  replSetName:  "001-rs"' >> /etc/mongod.conf
wait
service mongod restart
wait



