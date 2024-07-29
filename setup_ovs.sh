#!/bin/bash
#这个脚本负责基本网络拓扑环境的安装，我们的网络拓扑选择使用linux的网络命名空间以及ovs网桥的方式来构建
#ovs网桥搭建脚本一共需要一个参数，用来决定ovs网桥的datapath类型，选项有netdev和system
# 默认 datapath 类型
datapath_type="system"

# 解析命令行参数
while getopts "d:" opt; do
  case ${opt} in
    d )
      datapath_type=$OPTARG
      ;;
    \? )
      echo "Usage: cmd [-d datapath_type]"
      exit 1
      ;;
  esac
done

# 检查 datapath_type 参数是否合法
if [[ "$datapath_type" != "netdev" && "$datapath_type" != "system" ]]; then
  echo "Invalid datapath type: $datapath_type"
  echo "Allowed values are 'netdev' or 'system'."
  exit 1
fi

# 我们需要搭建三个ns，分别是ns1，ns2，ns3，其中ns1,ns2中都有一个veth对，veth对中的一个网络接口需要接到ovs网桥上。
# ns3负责后续测试时我们创建veth对接到ovs网桥上作为流表规模参数
build(){
    echo "Building network topology..."
    echo "creating network namespace ns1, ns2, ns3"
    ip netns add ns1
    ip netns add ns2
    ip netns add ns3
    echo "creating veth pair veth1 and veth2"
    ip link add veth1 type veth peer name veth_1
    ip link add veth2 type veth peer name veth_2
    ip link set veth1 netns ns1
    ip link set veth2 netns ns2
    ovs-vsctl add-br ovs_br0
    ovs-vsctl set bridge ovs_br0 datapath_type=$datapath_type
    ovs-vsctl add-port ovs_br0 veth_1
    ovs-vsctl add-port ovs_br0 veth_2
    ovs-ofctl del-flows ovs_br0
    ovs-ofctl add-flow ovs_br0 "in_port=veth_1, actions=output:veth_2"
    ovs-ofctl add-flow ovs_br0 "in_port=veth_2, actions=output:veth_1"
    # ip addr add 192.100.1.1/16 dev ovs_br0
    ifconfig ovs_br0 up
    ifconfig veth_1 up
    ifconfig veth_2 up
    ip netns exec ns1 ip addr add 192.100.1.2/16 dev veth1
    ip netns exec ns1 ip link set veth1 up
    ip netns exec ns2 ip addr add 192.100.1.3/16 dev veth2
    ip netns exec ns2 ip link set veth2 up
    echo "network topology build successfully"
}

iperfTest(){
    echo "Starting iperf test..."
    ip netns exec ns1 iperf3 -sD
    ip netns exec ns2 iperf3 -c 192.100.1.2
    echo "iperf test finished"
}
build
