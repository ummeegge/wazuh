# Wazuh agent for IPFire
This repository contains the build files for an [IPFire](https://www.ipfire.org) based [LFS](https://www.linuxfromscratch.org) system to build and [Wazuh agent](https://documentation.wazuh.com/current/upgrade-guide/wazuh-agent/index.html) . The build files are structured closely like in the [IPFire development section](https://www.ipfire.org/docs/devel/ipfire-2-x/addon-howto) for building Addons explained.
* So the CONF directory contains the configuration file.
* The LFS directory the building instructions.
* The PAKS directory the installation, uninstallation and update scripts.
* The ROOTFILE directory the installed files (lines without '#').

The wazuh_build_log should deliver an overview for potential interested people. Since Wazuh installs while building process so called "external" libraries, one can overview which they are and from where they come from.

## Building Wazuh agent on IPFire development environment
- A point which is not included in the build_files directory is the modification of the 'make.sh' file. Since a new package (Wazuh) should be build, there is the need to instruct the build system by adding a 'lfsmake2' line to do so. The whole line looks like this

```bash
--- make.sh_orig	2024-01-30 10:41:34.134813978 +0100
+++ make.sh	2024-01-29 18:30:47.329314521 +0100
@@ -1699,6 +1699,7 @@
   lfsmake2 perl-MIME-Base32
   lfsmake2 perl-URI-Encode
   lfsmake2 rsnapshot
+  lfsmake2 wazuh
 
   # Kernelbuild ... current we have no platform that need
   # multi kernel builds so KCFG is empty
```


- If all building files has been placed in the appropriate sections, there is the need to make the first build process to get the base directory in the chroot or ipfire-2.x/build directory. Like above mentioned, [Wazuh needs additional libraries](https://github.com/ummeegge/wazuh/blob/main/build_files/wazuh_build_log#L32) while building it and therefor the IPFire chroot environment needs an DNS resolution to download them via curl. To accomplish this, enter an DNS resolver of your choice under ipfire-2.x/build/etc/resolv.conf . This is not a good practice for the regular build process of IPFire Addons and should be circumvent by build the missing packages regular (own lfsmake) or if present by linking them but it seems that this are modified libraries so it might be problematic even if those libraries are already on the system to use them. May some communication with the Wazu developer brings more light into this.

## Installation
If the build process is finished a new package and a file has been produced which are located under '*/ipfire-2.x/packages'
```bash
╰─➤  ls packages | grep wazuh                                                                              1 ↵
meta-wazuh
wazuh-4.7.2-1.ipfire
```
at the time of writing this README, the [Wazuh version 4.7.2](https://github.com/wazuh/wazuh/archive/refs/tags/v4.7.2.tar.gz) has been used. Keep in mind to change the b2sum in the LFS if other version should be build. The 'wazuh-4.7.2-1.ipfire' contains all necessary files and also the binary for installation. To install it, take it to '/opt/pakfire/tmp' unpack it via
`tar xvf wazuh-4.7.2-1.ipfire`
so you get all needed files -->
```bash
$ ls /opt/pakfire/tmp      
files.tar.xz  install.sh  ROOTFILES  uninstall.sh  update.sh  wazuh-4.7.2-1.ipfire
```
to install the Wazuh agent execute the install.sh script. After it is finished, you can find the Wazuh installation under /var/ipfire/ossec. There is also an Sysvinit initscript and the symlinks for system start|stop|reboot are also set so you can use the common Sysvinit way with the following options

```bash
$ /etc/init.d/wazuh        
Usage: /etc/init.d/wazuh {start|stop|restart|status|info}
```

## Configuration

Before you start Wazuh, you need to configure it. The configuration file can be found under /var/ipfire/ossec/etc/ossec.conf. You need to add the IP address of the Wazuh server under the address line

`<address>{ENTER_HERE_WAZUH_SERVER_IP}</address>`

### Generate and add the agent key:

To building up an encrypted connection between the Wazuh agent on IPFire and the Wazuh server to transfer the data, a client key needs to be created on server side and imported to the agent. This can be done via the 'manage_agents' binary which can be found on IPFire agent under /var/ipfire/ossec/bin and on der Wazuh server under /var/ossec/bin . This process is quite simple and looks like this -->

Wazuh server:
* Login via ssh
* Become root via interactive shell (sudo -s)
* Go to /bin directory
* Execute manage_agents
* Add new agent
* Generate agent key
```bash
$ ssh wazuh-user@192.168.7.5
The authenticity of host '192.168.7.5 (192.168.7.5)' can't be established.
ECDSA key fingerprint is SHA256:r9eJRrxYuLMuFq1HokQ0msHji28GuaOezl+FA2DJb9U.
This host key is known by the following other names/addresses:
    ~/.ssh/known_hosts:5: 192.168.7.2
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added '192.168.7.5' (ECDSA) to the list of known hosts.
wazuh-user@192.168.7.5's password: 
Last login: Fri Dec 29 07:53:47 2023 from 192.168.7.3
wwwwww.           wwwwwww.          wwwwwww.
wwwwwww.          wwwwwww.          wwwwwww.
 wwwwww.         wwwwwwwww.        wwwwwww.
 wwwwwww.        wwwwwwwww.        wwwwwww.
  wwwwww.       wwwwwwwwwww.      wwwwwww.
  wwwwwww.      wwwwwwwwwww.      wwwwwww.
   wwwwww.     wwwwww.wwwwww.    wwwwwww.
   wwwwwww.    wwwww. wwwwww.    wwwwwww.
    wwwwww.   wwwwww.  wwwwww.  wwwwwww.
    wwwwwww.  wwwww.   wwwwww.  wwwwwww.
     wwwwww. wwwwww.    wwwwww.wwwwwww.
     wwwwwww.wwwww.     wwwwww.wwwwwww.
      wwwwwwwwwwww.      wwwwwwwwwwww.
      wwwwwwwwwww.       wwwwwwwwwwww.      oooooo
       wwwwwwwwww.        wwwwwwwwww.      oooooooo
       wwwwwwwww.         wwwwwwwwww.     oooooooooo
        wwwwwwww.          wwwwwwww.      oooooooooo
        wwwwwww.           wwwwwwww.       oooooooo
         wwwwww.            wwwwww.         oooooo


         WAZUH Open Source Security Platform
                  https://wazuh.com


[wazuh-user@wazuh-server ~]$ sudo -s
[root@wazuh-server wazuh-user]# cd /var/ossec/bin/
[root@wazuh-server bin]# ./manage_agents 


****************************************
* Wazuh v4.7.1 Agent manager.          *
* The following options are available: *
****************************************
   (A)dd an agent (A).
   (E)xtract key for an agent (E).
   (L)ist already added agents (L).
   (R)emove an agent (R).
   (Q)uit.
Choose your action: A,E,L,R or Q: A

- Adding a new agent (use '\q' to return to the main menu).
  Please provide the following:
   * A name for the new agent: IPFire
   * The IP Address of the new agent: 192.168.7.1
Confirm adding it?(y/n): y
Agent added with ID 001.

****************************************
* Wazuh v4.7.1 Agent manager.          *
* The following options are available: *
****************************************
   (A)dd an agent (A).
   (E)xtract key for an agent (E).
   (L)ist already added agents (L).
   (R)emove an agent (R).
   (Q)uit.
Choose your action: A,E,L,R or Q: E

Available agents: 
   ID: 001, Name: IPFire.local, IP: any
Provide the ID of the agent to extract the key (or '\q' to quit): 001

Agent key information for '001' is: 
MDA1IElQRmlyZS1wcmltZSAxOTIuMTY4Ljc1LjEgN2ZhZjU3ZmNiZmU4NzIxODYyYzk5MGM4MjBmNGMzYTUxZjA4ZWZhNzNkOGYwM2IwUhfTZzY5YmM4NzAxN2NjYQ==

** Press ENTER to return to the main menu.

```

On Wazuh agent on IPFire:
* SSH into IPFire
* Go to '/var/ipfire/ossec/bin'
* Execute 'manage_agents'
* Import agent key


```bash
# root @ IPFire in /var/ipfire/ossec/bin [9:37:28] 
$ ./manage_agents 


****************************************
* Wazuh v4.7.2 Agent manager.          *
* The following options are available: *
****************************************
   (I)mport key from the server (I).
   (Q)uit.
Choose your action: I or Q: I

* Provide the Key generated by the server.
* The best approach is to cut and paste it.
*** OBS: Do not include spaces or new lines.

Paste it here (or '\q' to quit): MDA1IElQRmlyZS1wcmltZSAxOTIuMTY4Ljc1LjEgN2ZhZjU3ZmNiZmU4NzIxODYyYzk5MGM4MjBmNGMzYTUxZjA4ZWZhNzNkOGYwM2IwUhfTZzY5YmM4NzAxN2NjYQ==

Agent information:
   ID:001
   Name:IPFire
   IP Address:192.168.7.1

Confirm adding it?(y/n): y
Added.


****************************************
* Wazuh v4.7.2 Agent manager.          *
* The following options are available: *
****************************************
   (I)mport key from the server (I).
   (Q)uit.
Choose your action: I or Q: Q

manage_agents: Exiting.
```



### Restart Wazuh agent:
After all changes has been done

* Add IP from Wazuh server into /var/ipfire/ossec/etc/ossec.conf
* Add new agent on Wazuh server
* Generate agent key on Wazuh server
* Import agent key into Wazuh agent

the Wazuh agent on IPFire can be started via '/etc/init.d/wazuh start' which looks like this -->
```bash
$ /etc/init.d/wazuh start 
Starting Wazuh agent...
Starting Wazuh v4.7.2...
Started wazuh-execd...
Started wazuh-agentd...
Started wazuh-syscheckd...
Started wazuh-logcollector...
Started wazuh-modulesd...
Completed.
Wazuh is running...
```

### Check on Wazuh server side if specific agent is active
Wazuh server offers also via CLI a possibility to get informations about an specific agent. Via
`/var/ossec/bin/agent_control -i {AGENT_ID}`
beneath some other informations, the status can be checked and should looks similar to this.

```bash
Wazuh agent_control. Agent information:
   Agent ID:   001
   Agent Name: IPFire
   IP address: 192.168.7.1
   Status:     Active

   Operating system:    Linux |IPFire.local |6.1.61-ipfire |#1 SMP PREEMPT_DYNAMIC Sat Nov  4 17:34:55 GMT 2023 |x86_64
   Client version:      Wazuh v4.7.2
   Configuration hash:  ab73af41699f13fdd81903b5f23d8d00
   Shared file hash:    4a8724b20dee0124ff9656783c490c4e
   Last keep alive:     1706604352

   Syscheck last started at:  Tue Jan 30 08:45:33 2024
   Syscheck last ended at:    Tue Jan 30 08:45:42 2024
```


That´s all check you Wazuh server webinterface for the newely added IPFire agent.

