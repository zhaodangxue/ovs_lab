#!/bin/bash
para_num=32
test_num_array=(0 10 50 100 200 500 1000 2000 5000 10000 50000 100000 500000) 
for test_num in ${test_num_array[@]}; do
echo "Testing flow num $test_num ..."
./test_arguement.sh -s $test_num -p $para_num -t 0
sleep 10
done