# Use Ubuntu 22.04 as the base image
FROM ubuntu:22.04
# Update and install necessary packages
RUN apt-get update
RUN apt-get install git -y
RUN apt install -y python3 python3-dev python3-pip
RUN apt-get install -y inetutils-ping
RUN apt-get install -y iperf
RUN apt-get install -y netperf
RUN apt-get install -y openvswitch-switch
RUN apt-get install -y openvswitch-common
RUN apt-get install -y iproute2
RUN apt-get install -y frr
RUN apt-get install -y bridge-utils
RUN apt-get install -y ebtables iptables
RUN git clone https://github.com/scottchiefbaker/dool.git
RUN python3 /dool/install.py
RUN apt-get install -y net-tools
RUN apt-get install -y ethtool
RUN apt-get install -y numactl