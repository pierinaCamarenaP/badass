#!/bin/bash

# Router 4 - VTEP with EVPN
# This script configures Linux bridge, VXLAN, and FRR for EVPN

echo "Configuring Router 4 (VTEP)..."

# Linux networking setup
echo "Setting up bridge and VXLAN..."
ip link add br0 type bridge
ip link set dev br0 up
ip link add vxlan10 type vxlan id 10 dstport 4789
ip link set dev vxlan10 up

# Add interfaces to bridge
brctl addif br0 vxlan10
brctl addif br0 eth0

echo "Bridge and VXLAN setup complete"

# Apply FRR configuration
echo "Applying FRR configuration..."
vtysh << 'EOF'
conf t
hostname frrr-4
no ipv6 forwarding
!
interface eth2
 ip address 10.1.1.10/30
 ip ospf area 0
!
interface lo
 ip address 1.1.1.4/32
 ip ospf area 0
!
router bgp 1
 neighbor 1.1.1.1 remote-as 1
 neighbor 1.1.1.1 update-source lo
 !
 address-family l2vpn evpn
  neighbor 1.1.1.1 activate
  advertise-all-vni
 exit-address-family
!
router ospf
!
write memory
exit
EOF

echo "Router 4 configuration complete!"
echo "Verify with the following commands:"
echo "  vtysh -c 'show ip route'"
echo "  vtysh -c 'show bgp summary'"
echo "  vtysh -c 'show bgp l2vpn evpn'"
echo "Check bridge: brctl show"