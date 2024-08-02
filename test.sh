#!/bin/bash
echo "Test all start"
echo "The following is the test of the para test"
./test_para.sh
sleep 10
echo "The following is the test of the flow table and port"
./test_flow_and_port.sh
echo "Test flow and port end"
sleep 10
echo "The following is the test of adding veth pair time"
./test_add_veth.sh
echo "Test all end"
