# rcInstaller

rcInstaller is a quick installer for rocket.chat that will do the work for you.
It will get you up and running with a rocket.chat server in about 6 minutes.
So you can spend your valuable time doing something else. It is currently built
to run and install on Ubuntu linux. 

rcInstaller will install rocket.chat, nginx, letsencrypt, and configure a
firewall for server. After doing such, it will configure nginx to act as a proxy
with a free SSL cert from letsencrypt.

# Install it now!

Copy and paste this into an Ubuntu server of your choice. Press enter, answer a
few questions and it will take care of the rest for you. Please note that this
should only be done on a unused ubuntu server. Installing this ontop of a server
with already running applications may have unintended consequences. Further, 
make sure the dns address you specify is valid as letsencrypt will be used to
generate you a free SSL cert.

```
wget -qO- https://raw.githubusercontent.com/Munzy/rcInstaller/master/inst.sh --no-check-certificate | bash
```

# Requirements

  - 1   CPU
  - 1G  RAM
  - Ubuntu 16.04 <
  - 64bit OS
  - https://rocket.chat/docs/installation/minimum-requirements
    

# Tested Enviornements
  - Ubuntu 16.04 64bit
  - Ubuntu 17.04 64bit
  

# Useful Info

https://rocket.chat/docs/

You can quickly upgrade your rocket.chat server to the latest by sshing into 
your server and running. It will also copy a backup of your current server to
/opt/rocket.chat.backup if anything goes wrong. Please make sure to give it time
after you run the updater as it will be updating the database and getting ready 
to go again.
```
/root/rcUpdater.sh
```

Letsencrypt will automatically be renewed monthly by /root/cert.sh. You can 
instantly get a new cert by running:
```
/root/cert.sh
```

This script installs a default firewall config, if you are running on a
non-standard ssh port you should edit the config of the firewall with:
```
nano /root/iptables.sh
```
Once you are done changing the config, you can apply the new rules by running:
```
/root/iptables.sh
```
Command that will start the rocket.chat server backend. This is done
automatically with crontab in newer releases. It will take 60 seconds after boot
to start up the server however. 
```
/root/runRC.sh
```



# Watch it in action!

[Watch it in action!](https://www.cameronmunroe.com/u/2016-10-05_10-46-49.gif)


# Hosts
You are a service provider, and you are curious if you can use this script in a
preconfigured package to quickly get users up and running on rocket.chat. The 
answer is yes, you may use this script for a preconfigured package and we gladly
encourage it. We ask that you leave the coffee links, but we won't be too upset
if you remove them. 
    

# Coffee!
If you like my work, please buy me a cup of coffee! 
https://www.cameronmunroe.com/coffee


# License

    # rcInstaller : A quick installer for rocket.chat
    # Copyright (C) {2017}  {Cameron Munroe ~ Mun }
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