

sudo yum install autoconf automake libtool graphviz hg kernel-devel



hg clone http://hg.code.sf.net/p/etherlabmaster/code ethercat-hg

cd ethercat-hg

touch NEWS README AUTHORS ChangeLog

autoreconf --force --install -v
./configure --disable-8139too

# Default --prefix is /opt/etherlab

make 
sudo make install
sudo make modules modules_install clean

#ethercat-1.5.2 (master)$ sudo modprobe -v ec_master main_devices="00:10:f3:4b:3a:bc"
#ethercat-1.5.2 (master)$ sudo modprobe -v ec_generic


