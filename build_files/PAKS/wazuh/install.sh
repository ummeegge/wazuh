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


# Add user and group wazuh if not already done.
if ! grep -q "wazuh" /etc/passwd; then
    groupadd wazuh;
    useradd -g wazuh -d /var/ipfire/ossec -s /sbin/nologin wazuh
    echo;
    echo "Have add user and group 'wazuh'";
else
    echo;
    echo "User already presant leave it as it is";
fi

extract_files

# Since installation fails with correct ownership,
# permissions needs to be set in here.
chown -R root:wazuh \
	/var/ipfire/ossec/active-response \
	/var/ipfire/ossec/agentless \
	/var/ipfire/ossec/backup \
	/var/ipfire/ossec/lib \
	/var/ipfire/ossec/queue \
	/var/ipfire/ossec/ruleset \
	/var/ipfire/ossec/.ssh \
	/var/ipfire/ossec/tmp \
	/var/ipfire/ossec/var \
	/var/ipfire/ossec/wodles
chown -R wazuh:wazuh \
	/var/ipfire/ossec/etc \
	/var/ipfire/ossec/logs \
	/var/ipfire/ossec/queue/*

# Add symlinks for start stop and restart wazuh init script.
ln -s ../init.d/wazuh /etc/rc.d/rc3.d/S5wazuh
ln -s ../init.d/wazuh /etc/rc.d/rc0.d/K95wazuh
ln -s ../init.d/wazuh /etc/rc.d/rc6.d/K95wazuh

# EOF

