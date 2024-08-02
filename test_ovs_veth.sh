#!/bin/bash
# 这个脚本负责在ns3中添加veth对，测量并发下veth的添加时间，用于比较速度
scale_num=0
# 最大并发数（根据系统资源和任务数量调整）
max_jobs=40

# 计数器
job_count=0
# 解析命令行参数，s是规模，d是是否用dool查看资源占用
while getopts "s:" opt; do
  case ${opt} in
    s )
      scale_num=$OPTARG
      ;;
    \? )
      echo "Usage: $0 [-s scale_num]"
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

AddVeth(){
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
}


AddVeth
wait
echo "Test add veth time complete."