#!/bin/bash

# Router 1 - Route Reflector (P3)
# This script configures the BGP route reflector for EVPN

echo "Configuring Router 1 (Route Reflector)..."

# Apply FRR configuration
vtysh << 'EOF'
conf t
hostname frrr-1
no ipv6 forwarding
!
interface eth0
 ip address 10.1.1.1/30
!
interface eth1
 ip address 10.1.1.5/30
!
interface eth2
 ip address 10.1.1.9/30
!
interface lo
 ip address 1.1.1.1/32
!
router bgp 1
 neighbor ibgp peer-group
 neighbor ibgp remote-as 1
 neighbor ibgp update-source lo
 bgp listen range 1.1.1.0/29 peer-group ibgp
 !
 address-family l2vpn evpn
  neighbor ibgp activate
  neighbor ibgp route-reflector-client
 exit-address-family
!
router ospf
 network 0.0.0.0/0 area 0
!
line vty
!
write memory
exit
EOF

echo "Router 1 configuration complete!"
echo "Verify with: vtysh -c 'show bgp summary'"