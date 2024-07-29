#!/bin/bash
veth_num=0
while getopts "s:" opt; do
  case ${opt} in
    s )
      veth_num=$OPTARG
      ;;
    \? )
      echo "Usage: $0 [-s veth_num]"
      exit 1
      ;;
  esac
done
file_name="./data/iperf_result/${veth_num}_numa.txt"
# 检查并创建目录
mkdir -p "$(dirname "$file_name")"
echo "Starting iperf test..."
echo "" > $file_name
chmod 777 $file_name
echo "Starting iperf server..."
ip netns exec ns1 numactl --cpunodebind=0 --membind=0 iperf3 -sD
sleep 10
echo "Running test iteration..."
for i in {1..5}; do
    echo "Running test iteration $i..."
    ip netns exec ns2 numactl --cpunodebind=0 --membind=0 iperf3 -c 192.100.1.2 -t 60 >> $file_name
    echo "Iteration $i complete. Waiting before next iteration..."
    sleep 10
done