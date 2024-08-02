#!/bin/bash
test_num_array=(0 10 50 100 200 500 1000 2000 5000 10000 50000) 
for test_num in ${test_num_array[@]}; do
echo "Testing veth num $test_num ..."
./setup_ovs.sh
./test_ovs_veth.sh -s $test_num
sleep 5
./teardown_ovs.sh
sleep 5
done
echo "Test add veth end"