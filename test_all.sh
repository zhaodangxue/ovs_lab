#!/bin/bash
echo "Test all start"
echo "The following is the test of the flow table"
./test_all_flow.sh
sleep 10
echo "The following is the test of the port"
./test_all_port.sh
echo "Test all end"
