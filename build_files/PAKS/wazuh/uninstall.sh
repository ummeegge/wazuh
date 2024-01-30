#!/bin/bash
############################################################################
#                                                                          #
# This file is part of the IPFire Firewall.                                #
#                                                                          #
# IPFire is free software; you can redistribute it and/or modify           #
# it under the terms of the GNU General Public License as published by     #
# the Free Software Foundation; either version 2 of the License, or        #
# (at your option) any later version.                                      #
#                                                                          #
# IPFire is distributed in the hope that it will be useful,                #
# but WITHOUT ANY WARRANTY; without even the implied warranty of           #
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the            #
# GNU General Public License for more details.                             #
#                                                                          #
# You should have received a copy of the GNU General Public License        #
# along with IPFire; if not, write to the Free Software                    #
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA #
#                                                                          #
# Copyright (C) 2007 IPFire-Team <info@ipfire.org>.                        #
#                                                                          #
############################################################################
#
. /opt/pakfire/lib/functions.sh
#stop_service ${NAME}
#make_backup ${NAME}
#remove_files

# Stop processes
if pgrep "wazuh" >/dev/null; then
    /etc/init.d/wazuh stop;
fi

# Remove files
rm -rfv \
	/var/ipfire/ossec \
	/etc/rc.d/init.d/wazuh

# Remove symlinks
WAZUHSYM=$(find /etc/rc.d/rc*.d -name "???wazuh")
if [[ -e "${WAZUHSYM}" ]]; then
	rm -rfv ${WAZUHSYM};
fi

# Delete user and group.
# Since wazuh logs are not available in messages,
# it is a good idea to clean passwd and groups up.
if grep -q "wazuh" /etc/passwd; then
	userdel wazuh
	groupdel wazuh
	echo "Have deleted group and user 'wazuh'... "
fi


# EOF
