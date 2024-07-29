#!/bin/bash
test_num_array = (0 1 5 10 50 100 200 500 1000 2000 5000) 
for test_num in ${test_num_array[@]}; do
    echo "Setting up environment..."
    ./setup_ovs.sh
    echo "Running test with adding $test_num veth pairs and ovs ports..."
    ./test_ovs.sh -s $test_num
    echo "Running iperf test on the same numa node..."
    ./test_iperf_numa.sh -s $test_num
    pkill -f 'test_iperf_numa'
    sleep 10
    echo "Running iperf test on different numa nodes..."
    ./test_iperf_numa_diff.sh -s $test_num
    echo "Tearing down environment..."
    ./teardown_ovs.sh
done