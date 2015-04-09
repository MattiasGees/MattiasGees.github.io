---
layout:     post
title:      "RHEV VM to OpenNebula VM"
subtitle:   "Setting up a new virtualization environment."
date:       2015-04-07 19:15:00
author:     "Mattias Gees"
header-img: "img/standard.jpg "
---

#Intro

For my last job I was responsible for setting up a new virtualization environment. The original virtualization platform was RHEV and I replaced it with OpenNebula. The advantage of OpenNebula is that it is giving us a lot more flexibility and it is easy to provision new Virtual Machines from a template. Also, this is a service we could give to the developers inside the company to set up their own virtual machines.

I built a whole new environment while the old RHEV environment was still running.

On the RHEV we had a couple of Windows machines I couldn't rebuild so I needed to migrate these to the OpenNebula environment. This was really easy as both systems are using KVM as virtualization layer. The biggest difference was that RHEV was using ISCSI and LVM as storage and our OpenNebula installation is NFS and file based.

#Howto

##RHEV Manager Shell

On the RHEV machine you need to look-up some details about the virtual hard drives before you can copy them.  
The first step is to make a connection to the RHEV Manager Shell.

```bash
[root@rhevmanager ~]# rhevm-shell

 ++++++++++++++++++++++++++++++++++++++++++

           Welcome to RHEVM shell

 ++++++++++++++++++++++++++++++++++++++++++

[RHEVM shell (disconnected)]# connect --url "https://localhost:8443/api" --user "username" --password "password" --insecure
```

When connected to the RHEV Manager shell, look-up the connected disks to the virtual machine you want to copy.

```bash
[RHEVM shell (connected)]# list disks --vm-identifier test-migrate

id         : dff21089-e06f-46db-b5ac-fd0aef7395ba
name       : CentOS64_Disk1
```

When you have the ids of the connected disks you can also look-up the details of that disk.

```bash
[RHEVM shell (connected)]#  show disk --id dff21089-e06f-46db-b5ac-fd0aef7395ba

id                               : dff21089-e06f-46db-b5ac-fd0aef7395ba
name                             : CentOS64_Disk1
actual_size                      : 10737418240
alias                            : CentOS64_Disk1
bootable                         : True
format                           : raw
image_id                         : 4a40e716-ea25-46e4-8f98-b7989fadb04f
interface                        : virtio
propagate_errors                 : False
provisioned_size                 : 10737418240
quota-id                         : 00000000-0000-0000-0000-000000000000
shareable                        : False
size                             : 10737418240
sparse                           : False
status-state                     : ok
storage_domains-storage_domain-id: 7f4acfe5-6eb7-402a-8b06-a157f8f50c0a
wipe_after_delete                : False
```

##Find the LVS

With the information you received from the RHEV Manager Shell you can find the LVS information of that disk by running the following command on the Storage Pool Manager (SPM) node.  
The path exists of /dev/&lt;storage_domains+storage_domain-id&gt;/&lt;image_id&gt;

```bash
$ lvdisplay /dev/7f4acfe5-6eb7-402a-8b06-a157f8f50c0a/4a40e716-ea25-46e4-8f98-b7989fadb04f
--- Logical volume ---
LV Path                /dev/7f4acfe5-6eb7-402a-8b06-a157f8f50c0a/4a40e716-ea25-46e4-8f98-b7989fadb04f
LV Name                4a40e716-ea25-46e4-8f98-b7989fadb04f
VG Name                7f4acfe5-6eb7-402a-8b06-a157f8f50c0a
LV UUID                17DXHn-JLxK-hbG2-Cm93-yLGW-Pw33-9Ir95Z
LV Write Access        read/write
LV Creation host, time node.example.local, 2014-06-10 15:06:25 +0200
LV Status              available
# open                 0
LV Size                10.00 GiB
Current LE             80
Segments               2
Allocation             inherit
Read ahead sectors     auto
- currently set to     256
Block device           253:26
```

##Make the LV available

Before you can start copying the LV, you need to make the LV available for use by running lvchange with the parameters -ay (activate + yes).

```bash
$ lvchange -ay /dev/7f4acfe5-6eb7-402a-8b06-a157f8f50c0a/4a40e716-ea25-46e4-8f98-b7989fadb04f
```

##Copy the image

On the receiving server (OpenNebula management node) run the following command. This command will save the data it receives on port 19000 to test1.img.

```bash
$  nc -l 19000|bzip2 -d|dd bs=1M of=/test1.img
```

On the sending server (SPM server) execute the following command.

```bash
$  dd bs=1M if=/dev/7f4acfe5-6eb7-402a-8b06-a157f8f50c0a/4a40e716-ea25-46e4-8f98-b7989fadb04f|bzip2 -c|nc <hostname.of.server> 19000
```

##Import into OpenNebula

Change to user oneadmin on the OpenNebula management node and run the following command.

```bash
$  oneimage create --datastore datastore_name --name test1 --path /test1.img --description "Imported test image"
```

It is also possible to use the Opennebula GUI and import the copied image that way.

![OpenNebula import](/img/opennebula_import.png "OpenNebula import")
