#!/bin/bash
#
#  Copyright (c) 2017 - Present Jeong Han Lee
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
# Date   : Thursday, October 26 22:29:45 CEST 2017
# version : 0.0.3

declare -gr SC_SCRIPT="$(realpath "$0")"
declare -gr SC_SCRIPTNAME=${0##*/}
declare -gr SC_TOP="$(dirname "$SC_SCRIPT")"


set -a
. ${SC_TOP}/ecat_setup.conf
set +a

. ${SC_TOP}/functions


function pushd { builtin pushd "$@" > /dev/null; }
function popd  { builtin popd  "$@" > /dev/null; }

declare -gr SUDO_CMD="sudo";
declare -g  WHICH_MASTER="";
declare -g  MASTER_REP_URL="";
declare -g  SD_UNIT_PATH="";


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



function build_master {

    printf "Building......\n\n"
    printf "Cloning ......\n\n"
    printf "%s\n" "${MASTER_REP_URL}"

    local autoreconf_option="subdir-objects"
    
    
    eval ${MASTER_REP_URL}

    printf "Moving to %s\n" "${WHICH_MASTER}"

    if [ "${WHICH_MASTER}" = "m-ethercat" ]; then
	WHICH_MASTER+="/ethercat-1.5.2"
    fi

    echo ${WHICH_MASTER}
    pushd ${WHICH_MASTER}

    
    touch ChangeLog

    # # Temp solution for ecmaster
    # if [ "${WHICH_MASTER}" = "ecmaster" ]; then
    # 	cp -f ../configure.ac .
    # fi

    autoreconf --force --install -v
    
    ./configure --disable-8139too
    make 
    ${SUDO_CMD} make install
    make modules
    ${SUDO_CMD} make modules_install
    
    popd
}


function setup_for_centos {

    ${SUDO_CMD} -v
    ${SUDO_CMD} yum -y install autoconf automake libtool graphviz hg kernel-devel
    
}



function setup_for_debian {


    ${SUDO_CMD} -v
    ${SUDO_CMD}  aptitude install -y autoconf automake libtool graphviz  mercurial
}





function yes_or_no_to_go {

    printf "\n";
    printf  ">>>> $1\n";
    read -p ">>>> Do you want to continue (y/n)? " answer
    case ${answer:0:1} in
	y|Y )
	    printf ">>>>  ...... ";
	    ;;
	* )
            printf "Stop here.\n";
	    exit;
    ;;
    esac

}



function setup_systemd {

    # Systemd setup

    ${SUDO_CMD} install -m 644 ${ECAT_SYSTEMD_PATH}/${ECAT_MASTER_SYSTEMD} ${SD_UNIT_PATH}/
    
    ${SUDO_CMD} systemctl daemon-reload;
    
    ${SUDO_CMD} systemctl enable ${ECAT_MASTER_SYSTEMD};
    
    mac_address=$(get_macaddr ${NETWORK0});
    
    m4 -D_MASTER0_DEVICE="${mac_address}" -D_DEVICE_MODULES="${ECAT_KMOD_GENERIC_NAME}" ${SC_TOP}/ethercat.conf.m4 > ${SC_TOP}/ethercat.conf_temp
    
    ${SUDO_CMD} install -m 644 ${SC_TOP}/ethercat.conf_temp /etc/ethercat.conf
    
    rm ${SC_TOP}/ethercat.conf_temp
}



function select_master {

    
    local selected_one=0;
    local selected_limit=3;
    local essmaster=2;
    local ecmaster=1;
    local etherlab=0;

    
    printf "\n";
    printf "There are three EtherCAT masters which can be installed : \n";
    printf "[0] ethercat-hg : etherlab open master\n";
    printf "[1] ecmaster    : PSI customized master (forked, patched) \n";
    printf "[2] m-ethercat  : ESS customized master (based on old PSI one)\n";
    printf "Select which master could be built, followed by [ENTER]:\n";
    read -e answer;

    selected_one=${answer};
    
    if [[ "$selected_one" -gt "$selected_limit" ]]; then
	printf "\n>>> Please select one of %s\n" "${selected_limit}"
	exit 1;
    fi
    if [[ "$selected_one" -lt "0" ]]; then
	printf "\n>>> Please select one number larger than 0\n" 
	exit 1;
    fi

    if [ "$selected_one" -eq ${etherlab} ]; then
	WHICH_MASTER="ethercat-hg"
	MASTER_REP_URL="hg clone http://hg.code.sf.net/p/etherlabmaster/code ${WHICH_MASTER}"
    elif [ "$selected_one" -eq ${ecmaster} ]; then
	WHICH_MASTER="ecmaster"
	MASTER_REP_URL="git clone https://github.com/icshwi/${WHICH_MASTER}"
    elif [ "$selected_one" -eq ${essmaster} ]; then
	WHICH_MASTER="m-ethercat"
	MASTER_REP_URL="git clone https://bitbucket.org/europeanspallationsource/${WHICH_MASTER}"
    else
	printf "We don't support your selection\n";
	printf "* ethercat-hg : etherlab open master\n";
	printf "* ecmaster    : PSI customized master\n";
	printf "* m-ethercat  :ESS customized master (based on old PSI one)\n";
	exit ;
    fi

    printf "\n"
    printf "The %s was selected\n" "$WHICH_MASTER";
    printf "Its command is %s\n" "${MASTER_REP_URL}";
    printf "\n\n";
    
    
}



dist=$(find_dist)

case "$dist" in
    *Debian*)
	printf "Debian is detected as $dist\n"
	
	SD_UNIT_PATH=${SD_UNIT_PATH01}
	
	read -p ">>>> Do you want to install packages (y/n)? " answer
	case ${answer:0:1} in
	    y|Y )
	    	setup_for_debian
	    ;;
	* )
            printf "Skip to install packages.\n";
	    
	    ;;
	esac
	;;
    *CentOS*)
	printf "CentOS is detected as $dist\n"
	SD_UNIT_PATH=${SD_UNIT_PATH02}
	
	read -p ">>>> Do you want to install packages (y/n)? " answer
	case ${answer:0:1} in
	    y|Y )
	    	setup_for_centos
	    ;;
	* )
            printf "Skip to install packages.\n";
	    
	    ;;
	esac
	;;
    *)
	printf "\n";
	printf "Doesn't support the detected $dist\n";
	printf "Please contact jeonghan.lee@gmail.com\n";
	printf "\n";
	exit;
	;;
esac



select_master
build_master
setup_systemd
put_udev_rule "${ECAT_KMOD_NAME}"



exit 0;



