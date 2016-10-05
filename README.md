# rcInstaller

rcInstaller is a quick installer for rocket.chat that will do the work for you.
So you can spend your valuable time doing something else. It is currently built
to run and install on Ubuntu linux. 

rcInstaller will install rocket.chat, nginx, letsencrypt. After doing such, it
will configure nginx to act as a proxy with a free SSL cert from letsencrypt.

# Install it now!

Copy and paste this into an Ubuntu server of your choice. Press enter, answer a
few questions and it will take care of the rest for you. Please note that this
should only be done on a unused ubuntu server. Installing this ontop of a server
with already running applications may have unintended consequences. Further, 
make sure the dns address you specify is valid as letsencrypt will be used to
generate you a free SSL cert.

```
wget -qO- https://raw.githubusercontent.com/Munroenet/rcInstaller/master/inst.sh --no-check-certificate | bash
```

# Requirements

  - 1   CPU
  - 1G  RAM
  - Ubuntu 16.04 <
  - 64bit OS
  - https://rocket.chat/docs/installation/minimum-requirements
    

# Tested Enviornements
  - Ubuntu 16.04 64bit
  

# Useful Docs 

https://rocket.chat/docs/

# Watch it in action!

![Watch it in action!](https://www.cameronmunroe.com/u/2016-10-05_10-46-49.gif)
    

# Coffee!
If you like my work, please buy me a cup of coffee! 
https://www.cameronmunroe.com/coffee


# License

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