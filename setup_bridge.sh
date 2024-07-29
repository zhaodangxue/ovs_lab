#!/bin/bash
#这个脚本负责基本网络拓扑环境的安装，我们的网络拓扑选择使用linux的网络命名空间以及linux bridge的方式来构建
build(){
    echo "set topology start"
    ip netns add ns1
    ip netns add ns2
    # ip netns show

    ip link add veth1 type veth peer name veth_1
    ip link add veth2 type veth peer name veth_2

    ip link set veth1 netns ns1
    ip link set veth2 netns ns2

    ip link add name linux_br0 type bridge
    ip link set dev veth_1 master linux_br0
    ip link set dev veth_2 master linux_br0

    ip addr add 192.100.1.1/16 dev linux_br0
    ip link set linux_br0 up
    ip link set veth_1 up
    ip link set veth_2 up
    ip netns exec ns1 ip addr add 192.100.1.2/16 dev veth1
    ip netns exec ns1 ip link set veth1 up
    ip netns exec ns2 ip addr add 192.100.1.3/16 dev veth2
    ip netns exec ns2 ip link set veth2 up
    echo "set topology end"
}
iperfTest(){
    echo "Starting iperf test..."
    ip netns exec ns1 iperf3 -sD
    ip netns exec ns2 iperf3 -c 192.100.1.2 -t 20
    echo "iperf test finished"
}
#构造网络拓扑
build
#iperf测试
# iperfTest