#!/bin/bash

cleanup() {
    echo "Cleaning up topology..."

    # Bring down and remove IP addresses
    ip netns exec ns1 ip link set dev veth1 down
    ip netns exec ns2 ip link set dev veth2 down
    ip addr del 192.100.1.1/16 dev linux_br0

    # Remove veth interfaces from namespaces
    ip netns exec ns1 ip link delete veth1
    ip netns exec ns2 ip link delete veth2

    # Remove bridge
    ip link set linux_br0 down
    ip link delete linux_br0 type bridge

    # Remove network namespaces
    ip netns delete ns1
    ip netns delete ns2

    echo "Cleanup completed."
}

cleanup