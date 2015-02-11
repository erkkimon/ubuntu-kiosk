# Architecture Overview
## Introduction

In brief, the infrastructure architecture consists of GNU/Linux kiosk computers that are updated automatically and configured centeredly.

The objectives of the infrastructure architecture are to
* decrease the need of administration.
* decrease risks in the field of cyber security.
* get rid of licence costs.
* enhance the end-user experience.
* prevent users from breaking and tweaking the system.
* decrease the amount of own servers.

The need for migration arises from the fact that the current infrastructure doesn't fulfil the needs listed above at all. Instead, the planned IT infrastructure architecture will fulfil the expectations way much better.

The reason of the existence of the school is to produce education as effectively as possible, and efficient education production is impossible if the IT infrastructure makes learning inefficient and administrative tasks of IT infrastructure reserve too much resources. All spent resources are away from somewhere else.

## Specifications

The infrastructure consists of kiosk nodes, a Github repository and Google Drive. The nodes are configured centeredly so that the administrative tasks require minimal effort. When an end-user starts using a node, a kiosk session is opened so nothing will be saved locally during the session. All created and modified files must be stored to Google Drive, which is integrated to the operating system.

### Ease of Maintenance in the Administrator's Point of View

Linux-based computers are practically [virus-free](http://librenix.com/?inode=21), extremely customizable and easy to administrate centeredly. The lack of viruses decreases the need of cleaning or – in the worst scenarios – reinstalling infected nodes. 

The most realistic security risk is that a piece of installed software is vulnerable. Nevertheless, the system and all installed packages can be updated automatically as soon as there is a security update available, thanks to the package management system of Ubuntu (apt-get). So everything is up to date automatically.

![Administrator does not need to interact with the nodes directly.](/../master/documentation/architecture.png?raw=true "Administrator doesn't need to interact with the nodes directly.")

The set of installed packages and configuration files can be altered through editing a system description file. The node's system's desired state is declared in an Ansible playbook, which tells the node what packages should be installed, what packages should not be installed and how certain things should be configured. 

The description file is stored in Github repository, and the nodes fetch this description file (playbook) at every boot and make sure that the system matches the description. If not, the system alters itself to match the description using Ansible. This kind of infrastructure architecture [scales infinitely.](http://docs.ansible.com/playbooks_intro.html).

The administrator can alter system configuration or install new applications on every node just by editing the description file and uploading it to Github. Github keeps track of versions and it makes it easy to fix possible misconfigurations.

Everything outsourcable is outsourced. The description file is stored on Github, so there is no need to maintain a master server to rule the slaves. Files are stored in Google Drive, which makes a file server useless and frees administration resources to improving the infrastructure instead of only maintaining it.

![Administrator only needs updates definition file, nodes to the dirty work.](/../master/documentation/kiosk-altering-process.png?raw=true "Administrator only needs updates definition file, nodes to the dirty work.")

The nodes run standalone operating systems, so no human interaction or server connection are needed to login or to keep them up-to-date, and this increases the redundancy of the infrastructure. Users won't even notice if Github is down and the software updates are downloaded and installed anyway silently in the background. 

The maintenance tasks including updating the system and making the system match the description file are run 10±5 minutes after every boot. Randomly scheduled updates reduce the simultanous load of the local network. Scheduling updates relatively with the boot is also handy because the maintenance tasks are performed whenever the node happens to be running.

### Ease of Use in the End-User's Point of View

The operating system on the nodes is Ubuntu 14.04.1. Gnome Shell (Gnome 3) was chosen because the end-user judges the operating system mostly by the looks of the operating system and ease of use. 

To enhance the quality of user experience the users are educated continuously to use the the operating system and to reduce the amount of unneeded, negative and time-consuming feedback. For example the background image can be transformed into a static instructor on the desktop. All unnecessary information (e.g. about available  updates) is hidden to avoid confusing the user.

# Setting Up Kiosk

## Basic Installation of the Operating System

Ubuntu 14.04.1 Live environment on the kiosk machine and start the installation. Go through the installation process setting the following details. Note, that this repo is work in process and these details are for the target environment. This repo will be made more modular and portable later.
- Language: Finnish
- Install third party software: yes
- Timezone: Helsinki
- Keyboard layout: Finnish 
- User information:
  - Name: edu-admin
  - Computer name: edu-kiosk-XXX
  - Username: edu-admin
  - Password: something good and rememberable

## Making the Computer Match the Description

Do the installation in "next-next-next" style until the installation is ready and the system wants to reboot. When the kiosk computer has rebooted, run the following command. 
```
sudo apt-get update &&
sudo apt-get -y install git ansible &&
printf "1 2 cron.daily sudo ansible-pull -d /home/edu-admin/.ansible-pull-cache -U https://github.com/erkkimon/ubuntu-kiosk.git -i \"localhost,\" > /home/edu-admin/ansible-log.txt\n\n" | sudo tee --append /etc/anacrontab &&
sudo ansible-pull -d /home/edu-admin/.ansible-pull-cache -U https://github.com/erkkimon/ubuntu-kiosk.git -i "localhost," > /home/edu-admin/ansible-log.txt &&
echo "Now the system matches the description and it's safe to reboot."
```

Wait until the terminal says that it's safe to reboot. Now reboot and from that boot on, the computer should match the current description. It also should make sure that the node makes itself to match the description once the description is updated.

# Frequently Asked Questions

**What to do? "E: Unable to lock the administration directory (var/lib/dpkg/), is another process using it?"**

Don't panic. Probably your system is just automatically updating the package list. This happens usually at the first boot of the system, if the setup script is being run very soon after the system has got itself up. Just wait a few minutes and try again, then it should work.

**How to generate .config/dconf/user for guest session?**

Launch guest session. In /tmp there is a folder for guest session's home, which includes .config/dconf/user. Just do the changes you want and copy /tmp/*/.config/dconf/user.
