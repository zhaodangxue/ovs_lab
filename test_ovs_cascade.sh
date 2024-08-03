#!/bin/bash

# 函数：创建网络拓扑
create_network() {
    echo "Creating network with $num_bridges OVS bridges..."

    # 创建网络命名空间
    sudo ip netns add ns1
    sudo ip netns add ns2

    # 创建veth对并连接到命名空间
    sudo ip link add veth0 type veth peer name veth1
    sudo ip link add veth2 type veth peer name veth3

    sudo ip link set veth0 netns ns1
    sudo ip netns exec ns1 ip link set dev veth0 name eth0

    sudo ip link set veth2 netns ns2
    sudo ip netns exec ns2 ip link set dev veth2 name eth0

    # 启用命名空间内的接口
    sudo ip netns exec ns1 ip link set dev eth0 up
    sudo ip netns exec ns2 ip link set dev eth0 up

    # 为命名空间内的接口分配IP地址
    sudo ip netns exec ns1 ip addr add 192.168.1.1/24 dev eth0
    sudo ip netns exec ns2 ip addr add 192.168.1.2/24 dev eth0

    # 创建并配置OVS网桥和补丁端口
    for ((i=0; i<num_bridges; i++)); do
        bridge="br$i"
        
        # 创建OVS网桥
        sudo ovs-vsctl add-br $bridge
        
        # 启用网桥
        sudo ip link set dev $bridge up
        
        # 为第一个网桥添加第一个veth接口
        if [ $i -eq 0 ]; then
            sudo ovs-vsctl add-port $bridge veth1
            sudo ip link set dev veth1 up
        fi
        
        # 为最后一个网桥添加第二个veth接口
        if [ $i -eq $((num_bridges-1)) ]; then
            sudo ovs-vsctl add-port $bridge veth3
            sudo ip link set dev veth3 up
        fi
    done

    # 将补丁端口连接在一起
    for ((i=0; i<num_bridges-1; i++)); do
        bridge="br$i"
        next_bridge="br$((i+1))"
        patch_port_src="patch-$bridge-to-$next_bridge"
        patch_port_dst="patch-$next_bridge-to-$bridge"

        # 创建并连接补丁端口
        sudo ovs-vsctl \
            -- add-port $bridge $patch_port_src \
            -- set interface $patch_port_src type=patch options:peer=$patch_port_dst \
            -- add-port $next_bridge $patch_port_dst \
            -- set interface $patch_port_dst type=patch options:peer=$patch_port_src

        # 启用补丁端口
        sudo ip link set dev $patch_port_src up
        sudo ip link set dev $patch_port_dst up
    done

    echo "Network setup complete with $num_bridges OVS bridges connected."
    # 检查并创建目录
    file_name="./data/iperf_result/cascade/${num_bridges}.txt"
    mkdir -p "$(dirname "$file_name")"
    echo "" > $file_name
    chmod 777 $file_name
    # 测试连接
    sudo ip netns exec ns1 iperf -s &
    sudo ip netns exec ns2 iperf -c 192.168.1.1 -t 60 -P 64 > $file_name
}

# 函数：清理网络拓扑
cleanup_network() {
    echo "Cleaning up the network..."

    # 删除OVS网桥及其所有端口
    for ((i=0; i<num_bridges; i++)); do
        bridge="br$i"
        sudo ovs-vsctl del-br $bridge
    done

    # 删除网络命名空间
    sudo ip netns del ns1
    sudo ip netns del ns2

    # 删除veth接口
    sudo ip link del veth0 2>/dev/null
    sudo ip link del veth2 2>/dev/null
    sudo pkill -f 'iperf'

    echo "Network cleanup complete."
}

# 检查是否提供了参数
if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Usage: $0 <create|cleanup> <number_of_bridges>"
    exit 1
fi

# 获取操作类型和网桥数量
action=$1
num_bridges=$2

# 检查网桥数量是否大于1
if [ "$num_bridges" -lt 2 ]; then
    echo "Error: Number of bridges must be at least 2"
    exit 1
fi

# 根据操作类型执行相应的函数
case "$action" in
    create)
        create_network
        ;;
    cleanup)
        cleanup_network
        ;;
    *)
        echo "Invalid action: $action"
        echo "Usage: $0 <create|cleanup> <number_of_bridges>"
        exit 1
        ;;
esac
