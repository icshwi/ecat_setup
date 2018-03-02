# Patches for Etherlab master (etehrcat-hg)

## Overview
This folder contains the patch to apply to the Etherlab master (etehrcat-hg)

These patches have been applyed to etehrcat-hg, stable-1.5 branch last commit available at that time

`2698:9e65f782e8a1 stable-1.5 Florian Pose	2018-02-13 17:16	Fixed scheduler settings in dc_user example; use CLOCK_MONOTONIC.`

## Patch description

This folder contains the following two patches:


1.  `etherlab-psi.patch` - Applies the changes made by PSI to ethercat-hg (`ecrt_domain_received`) 
2.  `fm-slave-process.patch` - Fixes the return value of the following functions in `fm_slave.c`

* `ec_fsm_slave_action_process_sdo`
* `ec_fsm_slave_action_process_sdo` 
* `ec_fsm_slave_action_process_reg` 
* `ec_fsm_slave_action_process_foe`
* `ec_fsm_slave_action_process_soe`

## Installation

### Select the base version

Clone the ethercat-hg repository into the ecat\_setup __top__ folder

``` bash
$ cd ecat_setup
$ hg clone http://hg.code.sf.net/p/etherlabmaster/code ethercat-hg
```
This will clone the __default__ branch. It has to be changed as follow:

``` bash
$ cd ethercat-hg
$ hg update -r 2698
```
Verify that you are in the right revision:

``` bash
$ hg id -nib
9e65f782e8a1 2698 stable-1.5
```

### Apply patches

Apply the required patches running the `apply_patch.sh` srcipt as follow:

``` bash
$ cd ../patches/etherlab/

$ ./apply_patch.sh etherlab-psi.patch [dry]
patching file include/ecrt.h
patching file lib/domain.c
patching file lib/domain.h
patching file lib/master.c
patching file master/cdev.c
patching file master/ioctl.c
patching file master/ioctl.h


$ ./apply_patch.sh fm-slave-process.patch [dry]
patching file master/fsm_slave.c
```
The optional `dry` argument runs the script in dry-run mode. This allows to verify if the patch can be applied without issues.

After applying the patches, verify that the repository is really changed

``` bash
$ cd ../../ethercat-hg/
$ hg id -nib
9e65f782e8a1+ 2698+ stable-1.5
```

### Install ethercat 

Move to the ecat\_setup __top__ folder and install etherlab master.

``` bash
$ cd ../../

# Edit ecat_setup.conf to set the proper EtherCAT interface

$ bash ecat_setup.bash 
...

There are three EtherCAT masters which can be installed : 
[0] ethercat-hg : etherlab open master
[1] ecmaster    : PSI customized master (forked, patched) 
[2] m-ethercat  : ESS customized master (based on old PSI one)
Select which master could be built, followed by [ENTER]:
... 
```
Select `0` to proceed.

Reboot the system to load kernel modules, then verify that ethercat modules are loaded and ethercat master is running
``` bash
$ lsmod | grep ec
ec_generic             16384  0
ec_master             262144  1 ec_generic
...

$ sudo dmesg | grep EtherCAT
$ sudo dmesg | grep EtherCAT
...
EtherCAT: Master driver 1.5.2 9e65f782e8a1+
EtherCAT: 1 master waiting for devices.
ec_generic: EtherCAT master generic Ethernet device module 1.5.2 9e65f782e8a1+
EtherCAT: Accepting XX:XX:XX:XX:XX:XX as main device for master 0.
EtherCAT 0: Starting EtherCAT-IDLE thread.
EtherCAT 0: Link state of ecm0 changed to UP.
EtherCAT 0: 8 slave(s) responding on main device.
EtherCAT 0: Slave states on main device: PREOP.
EtherCAT 0: Scanning bus.
EtherCAT 0: Bus scanning completed in 1268 ms.
EtherCAT 0: Using slave 0 as DC reference clock.
...

$ /opt/etherlab/bin/ethercat master
Master0
  Phase: Idle
  Active: no
...
```
