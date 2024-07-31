#!/bin/bash
#这个代表规模，可能是port规模，也可能是流表项规模
test_num=0
#这个代表并行数目
para_num=1
#这个type参数是为了区分不同的测试,目前我们设置为0代表流表项数目测试,1代表port数目测试
type=0
while getopts "s:p:t:" opt; do
  case ${opt} in
    s )
      test_num=$OPTARG
      ;;
    p )
      para_num=$OPTARG
      ;;
    t )
      type=$OPTARG
      ;;
    \? )
      echo "Usage: $0 [-s test_num] [-p para_num] [-t type]"
      exit 1
      ;;
  esac
done
echo "Setting up environment..."
./setup_ovs.sh
echo "Running test with adding $test_num ports or flow entries..."
if [ $type -eq 0 ]; then
    ./test_ovs_flow.sh -s $test_num
elif [ $type -eq 1 ]; then
    ./test_ovs_port.sh -s $test_num
else
    echo "type should be 0 or 1"
    exit 1
fi
echo "Running the normal iperf test..."
./test_iperf.sh -s $test_num -t $type
pkill -f 'iperf'
sleep 10
echo "Running the normal iperf test with different parallelism..."
./test_iperf_para.sh -s $test_num -p $para_num -t $type
pkill -f 'iperf'
sleep 10
echo "Running iperf test on the same numa node..."
./test_iperf_numa.sh -s $test_num -t $type
pkill -f 'iperf'
sleep 10
echo "Running iperf test on different numa nodes..."
./test_iperf_numa_diff.sh -s $test_num -t $type
pkill -f 'iperf'
sleep 10
echo "Running iperf test on different numa nodes with different parallelism..."
./test_iperf_numa_diff_para.sh -s $test_num -p $para_num -t $type
pkill -f 'iperf'
sleep 10
echo "Running iperf test on the same numa node with different parallelism..."
./test_iperf_numa_para.sh -s $test_num -p $para_num -t $type
sleep 10
echo "Tearing down environment..."
./teardown_ovs.sh