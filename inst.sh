#!/bin/bash

# =============================================================================
#               Rocket.Chat installer for (Ubunutu)
# =============================================================================
#
#   By:     Cameron Munroe ~ Mun
#   Ver:    1.0
#   git:    https://github.com/Munroenet/rcInstaller
#
#
#        If you enjoyed our work, please send us some coffee at
#            https://www.cameronmunroe.com/coffee/
#
# =============================================================================




# =============================================================================
# 	    rcInstaller License
# =============================================================================

    # rcInstaller : A quick installer for rocket.chat
    # Copyright (C) {2016}  {Cameron Munroe ~ Mun }
	# munroenet@gmail.com 

    # This program is free software: you can redistribute it and/or modify
    # it under the terms of the GNU General Public License as published by
    # the Free Software Foundation, either version 3 of the License, or
    # (at your option) any later version.

    # This program is distributed in the hope that it will be useful,
    # but WITHOUT ANY WARRANTY; without even the implied warranty of
    # MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    # GNU General Public License for more details.

    # You should have received a copy of the GNU General Public License
    # along with this program.  If not, see <http://www.gnu.org/licenses/>.

# =============================================================================
# 		End rcInsaller License
# =============================================================================


clear
echo "
# =============================================================================
#                   Rocket.chat installer!
# =============================================================================
#   Please answer the first few questions.
#   The domain name you specify should be valid, and pointing at this server.
#   It will be used by letsencrypt and the configuration of your server.
#   
#   This installer comes with no warranty, use at your own risk.
#
#   Also, please make sure to not install this on an already in use server.
#   Consequences may occur from running this script if you do.
#
# =============================================================================

"
# Get Server info for rocket.chat
read -p "Domain name you wish to use. i.e. demo.rocket.chat " rcURL </dev/tty
wait
read -p "Your email address. " rcEMAIL </dev/tty
wait

# Installing IPTables ruleset.

echo '#!/bin/bash'>/root/iptables.sh
echo '#####################################################' >>/root/iptables.sh
echo '#      IPv4'  >>/root/iptables.sh
echo '#####################################################' >>/root/iptables.sh
echo 'iptables -F' >>/root/iptables.sh
echo 'iptables -P INPUT DROP' >>/root/iptables.sh
echo 'iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT' >>/root/iptables.sh
echo 'iptables -A INPUT -i lo -m comment --comment "Allow loopback connections" -j ACCEPT' >>/root/iptables.sh
echo 'iptables -A INPUT -p icmp -m comment --comment "Allow Ping to work as expected" -j ACCEPT' >>/root/iptables.sh
echo 'iptables -A INPUT -p tcp -m multiport --destination-ports 22,80,443 -j ACCEPT' >>/root/iptables.sh
echo '#iptables -A INPUT -p udp -m multiport --destination-ports 655,161 -j ACCEPT' >>/root/iptables.sh
echo '#####################################################' >>/root/iptables.sh
echo '#      IPv6'  >>/root/iptables.sh
echo '#####################################################' >>/root/iptables.sh
echo 'ip6tables -F' >>/root/iptables.sh
echo 'ip6tables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT' >>/root/iptables.sh
echo 'ip6tables -A INPUT -i lo -m comment --comment "Allow Loopback Connections" -j ACCEPT' >>/root/iptables.sh
echo 'ip6tables -A INPUT -p icmpv6 -m comment --comment "Allow pings to fly!" -j ACCEPT' >>/root/iptables.sh
echo 'ip6tables -A INPUT -p tcp -m multiport --destination-ports 22,80,443 -j ACCEPT' >>/root/iptables.sh
echo '#ip6tables -A INPUT -p udp -m multiport --destination-ports 655,161 -j ACCEPT' >>/root/iptables.sh
echo 'ip6tables -A INPUT -j REJECT' >>/root/iptables.sh
echo 'ip6tables -A FORWARD -j REJECT' >>/root/iptables.sh

chmod +x /root/iptables.sh 
sed -i -e '$i \/root/iptables.sh\n' /etc/rc.local

( exec "/root/iptables.sh" )

# Getting newest apt-cache.
apt-get update
wait

# Let's do a quick upgrade.
apt-get dist-upgrade -y
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
apt-get install lsb-release -y
wait
apt-get install htop -y
wait
apt-get install psmisc -y
wait

# Creating Nginx slug.
echo "
# Upstreams
upstream backend {
    server 127.0.0.1:3000;
}

# HTTPS Server
server {

    # Enable HTTP2 by commenting out the other listen section, and uncommenting
    # this section.
    #listen 443 ssl http2 default_server;
    #listen [::]:443 ssl http2 default_server;

    listen 443 ssl default_server;
    listen [::]:443 ssl default_server;
    server_name ${rcURL};

    error_log /var/log/nginx/rocketchat.access.log;

    ssl on;
    ssl_certificate /etc/letsencrypt/live/${rcURL}/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/${rcURL}/privkey.pem;
    ssl_protocols TLSv1 TLSv1.1 TLSv1.2; # don’t use SSLv3 ref: POODLE

    location / {
        proxy_pass http://localhost:3000/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$http_host;

        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forward-For \$proxy_add_x_forwarded_for;
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

# Build updater.sh
echo "
#!/bin/bash

echo '

# =============================================================================
                            Updating Rocket.chat

            Rocket.chat will be shutdown, backed up, and restarted.
            Please give us a few moments to accomplish this.
            
# =============================================================================
'
killall -u rc
sleep 10
cp -r /opt/rocket.chat /opt/rocket.chat.backup
wait
wget 'https://rocket.chat/releases/latest/download' -O /tmp/rocket.chat.tgz
wait
cd /tmp
tar zxvf rocket.chat.tgz
wait
cp -r bundle/* /opt/rocket.chat/
wait
chown -R rc:rc /opt/rocket.chat
wait
sleep 10
wait
su -l - rc -c 'cd /opt/rocket.chat && screen -d -m node main.js'
echo '

# =============================================================================
                                Congrats!

        Rocket.chat should be updated, and starting up now.
        
        Please give us a few minutes for the server to fully update
        and get running though!
            
        If you enjoyed our work, please send us some coffee at
        https://www.cameronmunroe.com/coffee/

# =============================================================================
'
" >>/root/rcUpdater.sh
chmod +x /root/rcUpdater.sh

# Build Cert.sh
echo "
#!/bin/bash
rm -rf /opt/letsencrypt
git clone https://github.com/letsencrypt/letsencrypt /opt/letsencrypt

/opt/letsencrypt/letsencrypt-auto --renew-by-default -a webroot --webroot-path /var/www/html --email ${rcEMAIL} -d ${rcURL} auth
service nginx reload

" >> /root/cert.sh

chmod +x /root/cert.sh

echo "1 1 1 * * /root/cert.sh" >> /etc/cron.d/rocket.chat


# Install Monogodb depends.
apt-get install curl graphicsmagick -y
wait
apt-get install mongodb-server mongodb-clients mongodb -y
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


# create rocket.chat account (rc).
adduser --disabled-password --gecos "Rocket.Chat, [server room]" rc
wait

# Push config options to export.
echo "#Export for rocket.chat -> MongoDB Database"  >> /home/rc/.profile
echo "export MONGO_URL=mongodb://localhost:27017/rocketchat" >> /home/rc/.profile
echo "#Rocket.chat port." >> /home/rc/.profile
echo "export PORT=3000" >> /home/rc/.profile
echo "#Rocket.chat URL." >> /home/rc/.profile
echo "export ROOT_URL=https://${rcURL}/" >> /home/rc/.profile


# Get Rocket.chat
wget "https://rocket.chat/releases/latest/download" -O /tmp/rocket.chat.tgz
wait
cd /tmp
tar zxvf rocket.chat.tgz
wait
mv bundle /opt/rocket.chat
wait
cd /opt/rocket.chat/programs/server
npm install
wait
chown -R rc:rc /opt/rocket.chat

# Install startup.
sed -i -e '$i \su -l - rc -c "cd /opt/rocket.chat && screen -d -m node main.js"\n' /etc/rc.local

# Launch Rocket.chat.
su -l - rc -c 'cd /opt/rocket.chat && screen -d -m node main.js'

( exec "/root/cert.sh" )

echo "


# =============================================================================
                                Congrats!
                                
        Your new rocket.chat server should be running at
            https://${rcURL}/
        
        If you enjoyed our work, please send us some coffee at
            https://www.cameronmunroe.com/coffee/

# =============================================================================
"