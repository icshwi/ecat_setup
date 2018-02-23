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

### Install ethercat 

Move to the ecat\_setup __top__ folder and install etherlab master as always

``` bash
$ cd ../../

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

