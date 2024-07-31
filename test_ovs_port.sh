#!/bin/bash
# 这个脚本负责在ns3中添加port来实现流表规模测试，通过-s参数指定规模
scale_num=0
# 是否启用dool监测资源使用情况
dool_option=0
# 最大并发数（根据系统资源和任务数量调整）
max_jobs=40

# 计数器
job_count=0
# 解析命令行参数，s是规模，d是是否用dool查看资源占用
while getopts "s:d:" opt; do
  case ${opt} in
    s )
      scale_num=$OPTARG
      ;;
    d )
      dool_option=$OPTARG
      ;;
    \? )
      echo "Usage: $0 [-s scale_num] [-d dool_option]"
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
# 添加ovs网桥端口函数
process_port() {
    local i=$1
    echo "Adding port veth_$i to ovs_br0"
    ovs-vsctl add-port ovs_br0 veth_$i
}

AddPort(){
    echo "Adding veth pairs..."
    num=$((2 + scale_num))
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
    file_name="./data/veth_time/${scale_num}.txt"
    # 检查并创建目录
    mkdir -p "$(dirname "$file_name")"
    echo "veth pairs added successfully in $duration_veth seconds" > $file_name 2>&1
    job_count=0
    echo "veth pairs added successfully"
    echo "Adding ports."
    start_time_port=$(date +%s)  # 记录开始时间
    # 处理端口的添加
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
    end_time_port=$(date +%s)  # 记录结束时间
    duration_port=$((end_time_port - start_time_port))  # 计算时间差
    file_name="./data/port_time/${scale_num}.txt"
    # 检查并创建目录
    mkdir -p "$(dirname "$file_name")"
    echo "flows added successfully in $duration_port seconds" > $file_name 2>&1
}


doolTest(){
    scale=$((scale_num))
    file_name="./data/dool_result/${scale}_port.txt"
    # 检查并创建目录
    mkdir -p "$(dirname "$file_name")"
    dool --more --output  $file_name 1 10 &
}
AddPort
if [ $dool_option -eq 1 ]; then
    doolTest &
fi
wait
echo "Test port configuration complete."