#!/bin/bash
file_name_1="./data/iperf_result/normal_para.txt"
file_name_2="./data/iperf_result/numa_para.txt"
file_name_3="./data/iperf_result/numa_diff_para.txt"
para_nums=(1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32)
./setup_ovs.sh
./test_ovs.sh -s 0
echo "" > $file_name_1
echo "" > $file_name_2
echo "" > $file_name_3
for para_num in ${para_nums[@]}; do
echo "Running test iteration $para_num..."
echo "iperf normal test with $para_num parallel streams" >> $file_name_1
ip netns exec ns1 iperf -s &
sleep 5
ip netns exec ns2 iperf -c 192.100.1.2 -t 60 -P $para_num >> $file_name_1
pkill -f 'iperf'
sleep 5
echo "iperf numa test with $para_num parallel streams" >> $file_name_2
ip netns exec ns1 numactl --cpunodebind=0 --membind=0 iperf -s &
sleep 5
ip netns exec ns2 numactl --cpunodebind=0 --membind=0 iperf -c 192.100.1.2 -t 60 -P $para_num >> $file_name_2
pkill -f 'iperf'
sleep 5
echo "iperf numa diff test with $para_num parallel streams" >> $file_name_3
ip netns exec ns1 numactl --cpunodebind=1 --membind=1 iperf -s &
sleep 5
ip netns exec ns2 numactl --cpunodebind=0 --membind=0 iperf -c 192.100.1.2 -t 60 -P $para_num >> $file_name_3
pkill -f 'iperf'
sleep 5
done
./teardown_ovs.sh
echo "Test complete."
