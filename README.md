# ecat_setup

Edit the NETWORK0 according to your system. For example,

```
NETWORK0="eth1"
```

```
$ bash ecat_setup.bash 
Debian is detected as Debian jessie 8.9
>>>> Do you want to install packages (y/n)? y
[sudo] password for jhlee: 
......

There are three EtherCAT masters which can be installed : 
[0] ethercat-hg : etherlab open master
[1] ecmaster    : PSI customized master (forked, patched) 
[2] m-ethercat  : ESS customized master (based on old PSI one)
Select which master could be built, followed by [ENTER]:

...........

KERNEL=="EtherCAT[0-9]*", SUBSYSTEM=="EtherCAT", MODE="0666"
>>>> You are entering in  : cat_file
KERNEL=="EtherCAT[0-9]*", SUBSYSTEM=="EtherCAT", MODE="0666"
<<<< You are leaving from : cat_file

<<<< You are leaving from : put_udev_rule
```

Check your env and set them via

```
$ source set_path.bash 
```
```
$ tree /opt/etherlab/
/opt/etherlab/
├── [root     4.0K]  bin
│   └── [root     6.2M]  ethercat
├── [root     4.0K]  etc
│   ├── [root     1.8K]  ethercat.conf
│   ├── [root     4.0K]  init.d
│   │   └── [root     6.7K]  ethercat
│   └── [root     4.0K]  sysconfig
│       └── [root     2.0K]  ethercat
├── [root     4.0K]  include
│   ├── [root      80K]  ecrt.h
│   └── [root     3.7K]  ectty.h
├── [root     4.0K]  lib
│   ├── [root     191K]  libethercat.a
│   ├── [root      966]  libethercat.la
│   ├── [root       20]  libethercat.so -> libethercat.so.1.0.0
│   ├── [root       20]  libethercat.so.1 -> libethercat.so.1.0.0
│   ├── [root     106K]  libethercat.so.1.0.0
│   └── [root     4.0K]  systemd
│       └── [root     4.0K]  system
│           └── [root      262]  ethercat.service
└── [root     4.0K]  sbin
    └── [root     5.5K]  ethercatctl

9 directories, 13 files


$ sudo systemctl start ethercat.service 
$ sudo systemctl status ethercat.service 
● ethercat.service - EtherCAT Master Kernel Modules
   Loaded: loaded (/etc/systemd/system/ethercat.service; enabled)
   Active: active (exited) since Fri 2017-11-03 01:39:11 CET; 10s ago
  Process: 11218 ExecStart=/opt/etherlab/sbin/ethercatctl start (code=exited, status=0/SUCCESS)
 Main PID: 11218 (code=exited, status=0/SUCCESS)

Nov 03 01:39:11 hadron systemd[1]: Started EtherCAT Master Kernel Modules.
```



```
Libraries have been installed in:
   /opt/etherlab/lib

If you ever happen to want to link against installed libraries
in a given directory, LIBDIR, you must either use libtool, and
specify the full pathname of the library, or use the `-LLIBDIR'
flag during linking and do at least one of the following:
   - add LIBDIR to the `LD_LIBRARY_PATH' environment variable
     during execution
   - add LIBDIR to the `LD_RUN_PATH' environment variable
     during linking
   - use the `-Wl,-rpath -Wl,LIBDIR' linker flag
   - have your system administrator add LIBDIR to `/etc/ld.so.conf'

See any operating system documentation about shared libraries for
more information, such as the ld(1) and ld.so(8) manual pages.
```

```
iocuser@icslab-ecat01: ~$ tree -L 2 /opt/etherlab/
/opt/etherlab/
├── [root       22]  bin
│   └── [root     7.0M]  ethercat
├── [root       58]  etc
│   ├── [root     2.3K]  ethercat.conf
│   ├── [root       22]  init.d
│   └── [root       22]  sysconfig
├── [root       35]  include
│   ├── [root      80K]  ecrt.h
│   └── [root     3.7K]  ectty.h
├── [root      138]  lib
│   ├── [root     193K]  libethercat.a
│   ├── [root      948]  libethercat.la
│   ├── [root       20]  libethercat.so -> libethercat.so.1.0.0
│   ├── [root       20]  libethercat.so.1 -> libethercat.so.1.0.0
│   ├── [root     111K]  libethercat.so.1.0.0
│   └── [root       20]  systemd
└── [root       25]  sbin
    └── [root     5.6K]  ethercatctl
```
