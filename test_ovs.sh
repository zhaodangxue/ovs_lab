#!/bin/bash
# 这个脚本负责在ns3中添加veth网卡对来实现流表规模测试，通过-s参数指定规模
veth_num=0
dool_option=0
numa_option=0
# 最大并发数（根据系统资源和任务数量调整）
max_jobs=40

# 计数器
job_count=0
# 解析命令行参数，s是规模，d是是否用dool查看资源占用,n是是否绑定到同一个numa节点
while getopts "s:d:n:" opt; do
  case ${opt} in
    s )
      veth_num=$OPTARG
      ;;
    d )
      dool_option=$OPTARG
      ;;
    n )
      numa_option=$OPTARG
      ;;
    \? )
      echo "Usage: $0 [-s veth_num] [-d dool_option] [-n numa_option]"
      exit 1
      ;;
  esac
done

# 创建 veth 对的函数
create_veth() {
    local i=$1
    # echo "Creating veth pair: veth$i and veth_$i"
    ip link add veth$i type veth peer name veth_$i
    ip link set veth$i netns ns3
    ip netns exec ns3 ip link set veth$i up
    ip link set veth_$i up
}

# 添加端口并设置流表项的函数
process_port() {
    local i=$1
    # echo "Adding port veth_$i to ovs_br0 and setting flow"
    ovs-vsctl add-port ovs_br0 veth_$i
    ovs-ofctl add-flow ovs_br0 "in_port=veth_$i, actions=output:veth_1"
}

AddVeth(){
    echo "Adding veth pairs..."
    num=$((2 + veth_num))
    start_time_veth=$(date +%s)  # 记录开始时间
    # 处理 veth 对的创建
    for i in $(seq 3 $num); do
        # 调用创建函数并将其放入后台
        create_veth "$i" &
    
        # 递增计数器
        ((job_count++))

        # 如果达到最大并发数，则等待所有后台任务完成
        if ((job_count >= max_jobs)); then
            wait
            job_count=0  # 重置计数器以便下一批任务
        fi
    done
    wait 
    end_time_veth=$(date +%s)  # 记录结束时间
    duration_veth=$((end_time_veth - start_time_veth))  # 计算时间差
    file_name="./data/veth_time/${veth_num}.txt"
    # 检查并创建目录
    mkdir -p "$(dirname "$file_name")"
    echo "veth pairs added successfully in $duration_veth seconds" > $file_name 2>&1
    job_count=0
    echo "veth pairs added successfully"
    echo "add flows..."
    start_time_flow=$(date +%s)  # 记录开始时间
    # 处理端口的添加和流表设置
    for i in $(seq 3 $num); do
        # 调用处理函数并将其放入后台
        process_port "$i" &
    
        # 递增计数器
        ((job_count++))

        # 如果达到最大并发数，则等待所有后台任务完成
        if ((job_count >= max_jobs)); then
            wait
            job_count=0  # 重置计数器以便下一批任务
        fi
    done
    wait
    end_time_flow=$(date +%s)  # 记录结束时间
    duration_flow=$((end_time_flow - start_time_flow))  # 计算时间差
    file_name="./data/flow_time/${veth_num}.txt"
    # 检查并创建目录
    mkdir -p "$(dirname "$file_name")"
    echo "flows added successfully in $duration_flow seconds" > $file_name 2>&1
}

iperfTest(){
    scale=$((veth_num))
    file_name="./data/iperf_result/${scale}.txt"
    if [ $numa_option -eq 1 ]; then
        file_name="./data/iperf_result/${scale}_numa.txt"
    else
        file_name="./data/iperf_result/${scale}.txt"
    fi
    # 检查并创建目录
    mkdir -p "$(dirname "$file_name")"
    
    echo "Starting iperf test..."
    
    # 清空结果文件
    echo "" > $file_name
    chmod 777 $file_name
    
    # 启动 iperf3 服务器
    if [ $numa_option -eq 1 ]; then
        ip netns exec ns1 numactl --cpunodebind=0 --membind=0 iperf3 -sD
    else
        ip netns exec ns1 iperf3 -sD
    fi
    
    # 等待服务器启动
    sleep 10
    
    for i in {1..5}; do
        echo "Running test iteration $i..."
        
        if [ $numa_option -eq 1 ]; then
            ip netns exec ns2 numactl --cpunodebind=0 --membind=0 iperf3 -c 192.100.1.2 -t 60 >> $file_name 2>&1
        else
            ip netns exec ns2 iperf3 -c 192.100.1.2 -t 60 >> $file_name 2>&1
        fi
        
        # 等待一段时间后开始下一轮测试
        echo "Iteration $i complete. Waiting before next iteration..."
        sleep 10  # 调整等待时间，根据需要设置
    done
    
    # 停止 iperf3测试
    pkill -f 'iperf3'
    
    echo "iperf test finished"
}

doolTest(){
    scale=$((veth_num))
    file_name="./data/dool_result/${scale}.txt"
    # 检查并创建目录
    mkdir -p "$(dirname "$file_name")"
    dool --more --output  $file_name 10 60 &
}
AddVeth
# iperfTest &
if [ $dool_option -eq 1 ]; then
    doolTest &
fi
wait
echo "Test finished"