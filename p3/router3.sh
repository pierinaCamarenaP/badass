#!/bin/bash

# Router 3 - VTEP with EVPN
# This script configures Linux bridge, VXLAN, and FRR for EVPN

echo "Configuring Router 3 (VTEP)..."

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
hostname frrr-3
no ipv6 forwarding
!
interface eth1
 ip address 10.1.1.6/30
 ip ospf area 0
!
interface lo
 ip address 1.1.1.3/32
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

echo "Router 3 configuration complete!"
echo "Verify BGP EVPN with: vtysh -c 'show bgp l2vpn evpn'"
echo "Check bridge: brctl show"