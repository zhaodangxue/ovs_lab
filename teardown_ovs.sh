#!/bin/bash

# 定义网络命名空间列表
namespaces=("ns1" "ns2" "ns3")
ovs_bridge="ovs_br0"
# 最大并发数（根据系统资源和任务数量调整）
max_jobs=40

# 计数器
job_count=0

# 1. 处理网络命名空间
#for ns in "${namespaces[@]}"; do
    #echo "Processing namespace: $ns"
    
    # 将命名空间中的所有 veth 接口设置为 link down
    #ip netns exec "$ns" ip link show | awk -F': ' '/veth/ {print $2}' | while read -r veth; do
       #echo "Bringing down veth interface: $veth in namespace $ns"
       #ip netns exec "$ns" ip link set "$veth" down
    #done
#done

# 2. 处理 OVS 网桥
# 将网桥上的所有端口设置为 link down
ports=$(ovs-vsctl list-ports "$ovs_bridge")
# 处理端口的函数
process_port() {
    local port=$1
    # echo "Bringing down port: $port on bridge $ovs_bridge"
    ip link set "$port" down
    ip link del "$port"
}

# 处理端口
for port in $ports; do
    # 调用处理函数并将其放入后台
    process_port "$port" &
    
    # 递增计数器
    ((job_count++))

    # 如果达到最大并发数，则等待所有后台任务完成
    if ((job_count >= max_jobs)); then
        wait
        job_count=0
    fi
done
wait
job_count=0

# 删除端口函数
delete_port() {
    local port=$1
    local bridge=$2
    # echo "Deleting port: $port from bridge $bridge"
    ovs-vsctl del-port "$bridge" "$port"
}
# 处理端口删除
for port in $ports; do
    # 调用删除函数并将其放入后台
    delete_port "$port" "$ovs_bridge" &
    
    # 递增计数器
    ((job_count++))

    # 如果达到最大并发数，则等待所有后台任务完成
    if ((job_count >= max_jobs)); then
        wait
        job_count=0
    fi
done
wait
# 删除 OVS 网桥
echo "Deleting bridge: $ovs_bridge"
ovs-vsctl del-br "$ovs_bridge"
# 删除命名空间
for ns in "${namespaces[@]}"; do
    echo "Deleting namespace: $ns"
    ip netns del "$ns"
done
pkill -f 'test'
echo "Cleanup complete!"