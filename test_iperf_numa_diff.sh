#!/bin/bash
#这个代表规模，可能是port规模，也可能是流表项规模
scale_num=0
#这个type参数是为了区分不同的测试,目前我们设置为0代表流表项数目测试,1代表port数目测试
type=0
file_name=""
while getopts "s:t:" opt; do
  case ${opt} in
    s )
      scale_num=$OPTARG
      ;;
    t )
      type=$OPTARG
      ;;
    \? )
      echo "Usage: $0 [-s scale_num] [-t type]"
      exit 1
      ;;
  esac
done
if [ $type -eq 0 ]; then
    file_name="./data/iperf_result/flow/${scale_num}_numa_diff.txt"
elif [ $type -eq 1 ]; then
    file_name="./data/iperf_result/port/${scale_num}_numa_diff.txt"
else
    echo "type should be 0 or 1"
    exit 1
fi
# 检查并创建目录
mkdir -p "$(dirname "$file_name")"
echo "Starting iperf test..."
echo "" > $file_name
chmod 777 $file_name
echo "Starting iperf server..."
ip netns exec ns1 numactl --cpunodebind=1 --membind=1 iperf -s &
sleep 10
echo "Running test iteration..."
for i in {1..7}; do
    echo "Running test iteration $i..."
    ip netns exec ns2 numactl --cpunodebind=0 --membind=0 iperf -c 192.100.1.2 -t 60  >> $file_name
    echo "Iteration $i complete. Waiting before next iteration..." >> $file_name
    echo "Iteration $i complete. Waiting before next iteration..."
    sleep 10
done