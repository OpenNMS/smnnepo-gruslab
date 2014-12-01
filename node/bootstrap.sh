#!/bin/bash

echo "STORE $1 NODE $2 BOOTSTRAPPING!!!!!"

# Configure routes
cat > /etc/network/if-up.d/route-add << EOF
#!/bin/sh
ip route add 192.168.0.0/24 via 192.168.$1.1
EOF

chmod 755 /etc/network/if-up.d/route-add
ip route add 192.168.0.0/24 via 192.168.$1.1

# create swap file of 1GB (block size 1MB) due to very low RAM
/bin/dd if=/dev/zero of=/swapfile bs=1024 count=1048576
/sbin/mkswap /swapfile
/sbin/swapon /swapfile
/bin/echo '/swapfile          swap            swap    defaults        0 0' >> /etc/fstab

# Install Software
apt-get update;
apt-get install -y snmpd
apt-get install -y snmp #for debug purposes

# configure snmpd
NODE_IP=$(( $2+2 ))
cp /opt/provisioning/snmpd.conf.template /etc/snmp/snmpd.conf
sed -i s/%%STORE%%/$1/g /etc/snmp/snmpd.conf
sed -i s/%%NODE%%/${NODE_IP}/g /etc/snmp/snmpd.conf

# start snmpd service (it is not by default)
service snmpd start

# install tomcat 7 to monitor jmx and http
apt-get install -y tomcat7