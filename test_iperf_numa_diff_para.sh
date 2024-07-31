#!/bin/bash
veth_num=0
para_num=1
while getopts "s:p:" opt; do
  case ${opt} in
    s )
      veth_num=$OPTARG
      ;;
    p )
      para_num=$OPTARG
      ;;
    \? )
      echo "Usage: $0 [-s veth_num] [-p para_num]"
      exit 1
      ;;
  esac
done
file_name="./data/iperf_result/${veth_num}_numa_diff_para.txt"
# 检查并创建目录
mkdir -p "$(dirname "$file_name")"
echo "Starting iperf test..."
echo "" > $file_name
chmod 777 $file_name
echo "Starting iperf server..."
ip netns exec ns1 numactl --cpunodebind=1 --membind=1 iperf -s &
sleep 10
echo "Running test iteration..."
for i in {1..5}; do
    echo "Running test iteration $i..."
    ip netns exec ns2 numactl --cpunodebind=0 --membind=0 iperf -c 192.100.1.2  -t 60 -P $para_num  >> $file_name
    echo "Iteration $i complete. Waiting before next iteration..." >> $file_name
    echo "Iteration $i complete. Waiting before next iteration..."
    sleep 10
done