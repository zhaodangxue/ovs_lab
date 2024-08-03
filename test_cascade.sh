#!/bin/bash
test_num_array=(2 4 10 20 50) 
for test_num in ${test_num_array[@]}; do
echo "Testing cascade num $test_num ..."
./test_ovs_cascade.sh create $test_num
sleep 5
./test_ovs_cascade.sh cleanup $test_num
sleep 5
done
echo "Test ovs cascade end"