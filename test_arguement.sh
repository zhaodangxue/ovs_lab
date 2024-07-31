test_num=0
para_num=1
while getopts "s:p:" opt; do
  case ${opt} in
    s )
      test_num=$OPTARG
      ;;
    p )
      para_num=$OPTARG
      ;;
    \? )
      echo "Usage: $0 [-s test_num] [-p para_num]"
      exit 1
      ;;
  esac
done
echo "Setting up environment..."
./setup_ovs.sh
echo "Running test with adding $test_num veth pairs and ovs ports..."
./test_ovs.sh -s $test_num
echo "Running the normal iperf test..."
./test_iperf.sh -s $test_num
pkill -f 'iperf'
sleep 10
echo "Running the normal iperf test with different parallelism..."
./test_iperf_para.sh -s $test_num -p $para_num
pkill -f 'iperf'
sleep 10
echo "Running iperf test on the same numa node..."
./test_iperf_numa.sh -s $test_num
pkill -f 'iperf'
sleep 10
echo "Running iperf test on different numa nodes..."
./test_iperf_numa_diff.sh -s $test_num
pkill -f 'iperf'
sleep 10
echo "Running iperf test on different numa nodes with different parallelism..."
./test_iperf_numa_diff_para.sh -s $test_num -p $para_num
pkill -f 'iperf'
sleep 10
echo "Running iperf test on the same numa node with different parallelism..."
./test_iperf_numa_para.sh -s $test_num -p $para_num
sleep 10
echo "Tearing down environment..."
./teardown_ovs.sh