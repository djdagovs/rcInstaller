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


# Installing IPTables ruleset.

# Get Server info for rocket.chat
read -p "Domain name you wish to use. i.e. demo.rocket.chat " rcURL
wait
read -p "Your email address. " rcEMAIL
wait

echo '#!/bin/bash'>/root/iptables.sh
echo '#####################################################' >>/root/iptables.sh
echo '#      IPv4'  >>/root/iptables.sh
echo '#####################################################' >>/root/iptables.sh
echo 'iptables -F' >>/root/iptables.sh
echo 'iptables -P INPUT DROP' >>/root/iptables.sh
echo 'iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT' >>/root/iptables.sh
echo 'iptables -A INPUT -i lo -m comment --comment "Allow loopback connections" -j ACCEPT' >>/root/iptables.sh
echo '#iptables -A INPUT -i tun0 -m comment --comment "Allow Tinc connections" -j ACCEPT' >>/root/iptables.sh
echo 'iptables -A INPUT -p icmp -m comment --comment "Allow Ping to work as expected" -j ACCEPT' >>/root/iptables.sh
echo 'iptables -A INPUT -p tcp -m multiport --destination-ports 22,80,443 -j ACCEPT' >>/root/iptables.sh
echo '#iptables -A INPUT -p udp -m multiport --destination-ports 655,161 -j ACCEPT' >>/root/iptables.sh
echo '#####################################################' >>/root/iptables.sh
echo '#      IPv6'  >>/root/iptables.sh
echo '#####################################################' >>/root/iptables.sh
echo 'ip6tables -F' >>/root/iptables.sh
echo 'ip6tables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT' >>/root/iptables.sh
echo 'ip6tables -A INPUT -i lo -m comment --comment "Allow Loopback Connections" -j ACCEPT' >>/root/iptables.sh
echo 'ip6tables -A INPUT -i tun0 -m comment --comment "Allow TINC Connections" -j ACCEPT' >>/root/iptables.sh
echo 'ip6tables -A INPUT -p icmpv6 -m comment --comment "Allow pings to fly!" -j ACCEPT' >>/root/iptables.sh
echo 'ip6tables -A INPUT -p tcp -m multiport --destination-ports 22,80,443 -j ACCEPT' >>/root/iptables.sh
echo '#ip6tables -A INPUT -p udp -m multiport --destination-ports 655,161 -j ACCEPT' >>/root/iptables.sh
echo 'ip6tables -A INPUT -j REJECT' >>/root/iptables.sh
echo 'ip6tables -A FORWARD -j REJECT' >>/root/iptables.sh

chmod +x /root/iptables.sh 
sed -i -e '$i \cd /root/ && ./iptables.sh\n' /etc/rc.local

( exec "/root/iptables.sh" )

# Getting newest apt-cache.
apt-get update
wait

# Installing basic depends.
apt-get install screen -y
wait
apt-get install fail2ban -y
wait
apt-get install nano -y
wait
apt-get install haveged -y
wait
apt-get install vnstat -y
wait
apt-get install ca-certificates -y
wait
apt-get install nginx -y
wait
apt-get install git -y
wait


# Let's do a quick upgrade.
apt-get dist-upgrade -y
wait

# Creating Nginx slug.
echo "
# Upstreams
upstream backend {
    server 127.0.0.1:3000;
}

# HTTPS Server
server {
    listen 443 ssl http2 default_server;
    listen [::]:443 ssl http2 default_server;
    server_name ${rcURL};

    error_log /var/log/nginx/rocketchat.access.log;

    ssl on;
    ssl_certificate /etc/nginx/certificate.crt;
    ssl_certificate_key /etc/nginx/certificate.key;
    ssl_protocols TLSv1 TLSv1.1 TLSv1.2; # don’t use SSLv3 ref: POODLE

    location / {
        proxy_pass http://IP:3000/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $http_host;

        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forward-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forward-Proto http;
        proxy_set_header X-Nginx-Proxy true;

        proxy_redirect off;
    }
}" >> /etc/nginx/conf.d/rocket.chat.conf

mv /var/www/html/index.html /var/www/html/index.html.old
echo "
<html>
    <head>
        <meta http-equiv='refresh' content=\"0;URL='https://${rcURL}'\" />  
    </head>
    <body>
        <h1>Redirecting to https://</h1>
    </body>
</html>
" >>/var/www/html/index.html

# Build Cert.sh
echo "
#!/bin/bash
rm -rf /opt/letsencrypt
git clone https://github.com/letsencrypt/letsencrypt /opt/letsencrypt

letsencrypt --renew-by-default -a webroot --webroot-path /var/www/html --email ${rcEMAIL} -d ${rcURL} auth
service nginx reload

" >> /root/cert.sh

chmod +x cert.sh

echo "1 1 1 * * /root/cert.sh" >> /etc/cron.d/rocket.chat

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

#initiate commands to MongoDB.
mongo --eval "rs.initiate()"
wait

# create rocket.chat account (rc).
adduser --disabled-password --gecos "Rocket.Chat, [server room], [127.0.0.1], [:::1]" rc
wait

# Push config options to export.
echo "#Export for rocket.chat -> MongoDB Oplog." >> /home/rc/.profile
echo "export MONGO_OPLOG_URL=mongodb://localhost:27017/local?replicaSet=001-rs" >> /home/rc/.profile
echo "#Export for rocket.chat -> MongoDB Database"  >> /home/rc/.profile
echo "export MONGO_URL=mongodb://localhost:27017/rocketchat" >> /home/rc/.profile
echo "#Rocket.chat port." >> /home/rc/.profile
echo "export PORT=3000" >> /home/rc/.profile
echo "Rocket.chat URL." >> /home/rc/.profile
echo "export ROOT_URL=https://${rcURL}/" >> /home/rc/.profile


# Get Rocket.chat
wget "https://rocket.chat/releases/latest/download" -O /tmp/rocket.chat.tgz
wait
tar zxvf rocket.chat.tgz
wait
mv bundle /opt/rocket.chat
wait
cd /opt/rocket.chat/programs/server
npm install
wait

# Install startup.
sed -i -e "$i \su -l - rc -c 'cd /opt/rocket.chat && screen -d -m node main.js'\n" /etc/rc.local

# Launch Rocket.chat.
su -l - rc -c 'cd /opt/rocket.chat && screen -d -m node main.js'

( exec "/root/cert.sh" )