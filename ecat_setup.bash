#!/bin/bash
#
#  Copyright (c) 2017 - Present European Spallation Source ERIC
#
#  The program is free software: you can redistribute
#  it and/or modify it under the terms of the GNU General Public License
#  as published by the Free Software Foundation, either version 2 of the
#  License, or any newer version.
#
#  This program is distributed in the hope that it will be useful, but WITHOUT
#  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
#  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
#  more details.
#
#  You should have received a copy of the GNU General Public License along with
#  this program. If not, see https://www.gnu.org/licenses/gpl-2.0.txt
#
# Author : Jeong Han Lee
# email  : jeonghan.lee@gmail.com
# Date   : Tuesday, October 17 16:08:41 CEST 2017
# version : 0.0.1

declare -gr SC_SCRIPT="$(realpath "$0")"
declare -gr SC_SCRIPTNAME=${0##*/}
declare -gr SC_TOP="$(dirname "$SC_SCRIPT")"


set -a
. ${SC_TOP}/ecat_setup.conf
set +a

. ${SC_TOP}/functions


declare -gr SUDO_CMD="sudo";


# arg1 : KMOD NAME
# arg2 : target_rootfs, if exists
function put_udev_rule(){

    local func_name=${FUNCNAME[*]};  __ini_func ${func_name};
    local kmod_name=${1}
    local target_rootfs=${2}
    local udev_rules_dir="${target_rootfs}/etc/udev/rules.d"
    local rule=""
    local target=""
 
    case "$kmod_name" in     
	${MRF_KMOD_NAME})
	    rule="KERNEL==\"uio*\", ATTR{name}==\"mrf-pci\", MODE=\"0${KMOD_PERMISSON}\"";
	    target="${udev_rules_dir}/99-${MRF_KMOD_NAME}ioc2.rules";
	    ;;
	${SIS_KMOD_NAME})
	    rule="KERNEL==\"sis8300-[0-9]*\", NAME=\"%k\", MODE=\"0${KMOD_PERMISSON}\"";
	    target="${udev_rules_dir}/99-${SIS_KMOD_NAME}.rules";
	    ;;
	${ECAT_KMOD_NAME})
	    rule="KERNEL==\"EtherCAT[0-9]*\", SUBSYSTEM==\"EtherCAT\", MODE=\"0${KMOD_PERMISSON}\"";
	    target="${udev_rules_dir}/99-${ECAT_KMOD_NAME}.rules";
	    ;;
	*)
	    # no rule, but create a dummy file
	    rule=""
	    target="${udev_rules_dir}/99-${kmod_name}.rules";
	    ;;
    esac
  
    printf "Put the udev rule : %s in %s to be accessible via an user.\n" "$rule" "$target";
    printf_tee "$rule" "$target";
    cat_file ${target}
    __end_func ${func_name};
}


${SUDO_CMD} -v



${SUDO_CMD} yum install autoconf automake libtool graphviz hg kernel-devel



hg clone http://hg.code.sf.net/p/etherlabmaster/code ethercat-hg

cd ethercat-hg

touch ChangeLog
autoreconf --force --install -v

./configure --disable-8139too
# #

# # # Default --prefix is /opt/etherlab

make 
sudo make install

# iocuser@icslab-ecat01: etherlab$ tree -L 3
# .
# ├── [root       22]  bin
# │   └── [root     7.0M]  ethercat
# ├── [root       58]  etc
# │   ├── [root     2.3K]  ethercat.conf
# │   ├── [root       22]  init.d
# │   │   └── [root     6.7K]  ethercat
# │   └── [root       22]  sysconfig
# │       └── [root     2.3K]  ethercat
# ├── [root       35]  include
# │   ├── [root      80K]  ecrt.h
# │   └── [root     3.7K]  ectty.h
# ├── [root      138]  lib
# │   ├── [root     193K]  libethercat.a
# │   ├── [root      948]  libethercat.la
# │   ├── [root       20]  libethercat.so -> libethercat.so.1.0.0
# │   ├── [root       20]  libethercat.so.1 -> libethercat.so.1.0.0
# │   ├── [root     111K]  libethercat.so.1.0.0
# │   └── [root       20]  systemd
# │       └── [root       30]  system
# └── [root       25]  sbin
#     └── [root     5.6K]  ethercatctl

# 9 directories, 12 files


# iocuser@icslab-ecat01: /$ tree /opt/etherlab/lib/
# /opt/etherlab/lib/
# ├── [root     193K]  libethercat.a
# ├── [root      948]  libethercat.la
# ├── [root       20]  libethercat.so -> libethercat.so.1.0.0
# ├── [root       20]  libethercat.so.1 -> libethercat.so.1.0.0
# ├── [root     111K]  libethercat.so.1.0.0
# └── [root       20]  systemd
#     └── [root       30]  system
#         └── [root      790]  ethercat.service

# 2 directories, 6 files



# sudo make modules modules_install clean

#ethercat-1.5.2 (master)$ sudo modprobe -v ec_master main_devices="00:10:f3:4b:3a:bc"
#ethercat-1.5.2 (master)$ sudo modprobe -v ec_generic


put_udev_rule "${ECAT_KMOD_NAME}"


# Systemd setup

${SUDO_CMD} install -m 644 ${ECAT_SYSTEMD_PATH}/${ECAT_MASTER_SYSTEMD} ${SD_UNIT_PATH01}/

${SUDO_CMD} systemctl daemon-reload;

${SUDO_CMD} systemctl enable ${ECAT_MASTER_SYSTEMD};

mac_address=$(get_macaddr ${NETWORK0});


m4 -D_MASTER0_DEVICE="${mac_address}" -D_DEVICE_MODULES="${ECAT_KMOD_GENERIC_NAME}" ${SC_TOP}/ethercat.conf.m4 > ${SC_TOP}/ethercat.conf_temp

${SUDO_CMD} install -m 644 ${SC_TOP}/ethercat.conf_temp /etc/ethercat.conf

rm ${SC_TOP}/ethercat.conf_temp



