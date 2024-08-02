#!/bin/bash
# 这个脚本负责在ns3中添加对应流表项对来实现流表规模测试，通过-s参数指定规模
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

# 处理函数，用于生成流表项
process_flow() {
    local i=$1
    # 计算 IP 地址的各个字节
    x=$(((i / 65536) + 1))
    z=$((i % 256))
    y=$((i % 65536 / 256))

    # 生成 IP 地址
    ip_address="192.$x.$y.$z"

    # 打印生成的 IP 地址
    echo "Generated IP address: $ip_address"
    # 生成流表项
    ovs-ofctl add-flow ovs_br0 "ip,nw_src=$ip_address,actions=drop"
}

AddFlow(){
    echo "Adding flows."
    num=$((2 + scale_num))
    job_count=0
    # echo "veth pairs added successfully"
    echo "add flows..."
    start_time_flow=$(date +%s)  # 记录开始时间
    # 处理流表项的添加
    for i in $(seq 3 $num); do
        # 调用处理函数并将其放入后台
        process_flow "$i" &
    
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
    file_name="./data/flow_time/${scale_num}.txt"
    # 检查并创建目录
    mkdir -p "$(dirname "$file_name")"
    echo "flows added successfully in $duration_flow seconds" > $file_name 2>&1
}


doolTest(){
    scale=$((scale_num))
    file_name="./data/dool_result/${scale}_flow.txt"
    # 检查并创建目录
    mkdir -p "$(dirname "$file_name")"
    dool --more --output  $file_name 1 10 &
}
AddFlow
if [ $dool_option -eq 1 ]; then
    doolTest &
fi
wait
echo "Test flow configuration finished"