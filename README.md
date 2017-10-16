# ecat_setup


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