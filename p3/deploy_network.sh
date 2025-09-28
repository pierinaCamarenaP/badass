#!/bin/bash

# Complete VXLAN EVPN Network Deployment Script
# This script helps deploy the entire network configuration

echo "VXLAN EVPN Network Deployment Helper"
echo "===================================="
echo ""

# Function to make scripts executable
make_executable() {
    chmod +x router1.sh router2.sh router3.sh router4.sh 2>/dev/null || true
}

# Function to check if FRR is running
check_frr() {
    if ! systemctl is-active --quiet frr; then
        echo "Warning: FRR service is not running. Start with: sudo systemctl start frr"
        return 1
    fi
    return 0
}

# Function to check if bridge-utils is installed
check_bridge_utils() {
    if ! command -v brctl &> /dev/null; then
        echo "Error: bridge-utils not installed. Install with: sudo apt install bridge-utils"
        return 1
    fi
    return 0
}

echo "Pre-deployment checks:"
echo "----------------------"

# Check dependencies
check_frr
check_bridge_utils

echo ""
echo "Available deployment options:"
echo "1. Deploy all routers (requires running on each router separately)"
echo "2. Deploy specific router"
echo "3. Show configuration summary"
echo "4. Troubleshooting commands"

read -p "Select option (1-4): " choice

case $choice in
    1)
        echo ""
        echo "To deploy all routers, run the appropriate script on each router:"
        echo "Router 1 (Route Reflector): ./router1.sh"
        echo "Router 2 (VTEP):           ./router2.sh"
        echo "Router 3 (VTEP):           ./router3.sh" 
        echo "Router 4 (VTEP):           ./router4.sh"
        echo ""
        make_executable
        echo "Scripts are now executable."
        ;;
    2)
        echo ""
        echo "Which router are you configuring?"
        echo "1) Router 1 (Route Reflector)"
        echo "2) Router 2 (VTEP)"
        echo "3) Router 3 (VTEP)"
        echo "4) Router 4 (VTEP)"
        read -p "Router number: " router_num
        
        make_executable
        case $router_num in
            1) ./router1.sh ;;
            2) ./router2.sh ;;
            3) ./router3.sh ;;
            4) ./router4.sh ;;
            *) echo "Invalid selection" ;;
        esac
        ;;
    3)
        cat << 'EOF'

Network Topology Summary:
========================
Router 1 (1.1.1.1): BGP Route Reflector
├── eth0: 10.1.1.1/30 → Router 2 
├── eth1: 10.1.1.5/30 → Router 3
└── eth2: 10.1.1.9/30 → Router 4

Router 2 (1.1.1.2): VTEP
├── eth0: 10.1.1.2/30 → Router 1
└── eth1: Bridged to VXLAN 10

Router 3 (1.1.1.3): VTEP  
├── eth1: 10.1.1.6/30 → Router 1
└── eth0: Bridged to VXLAN 10

Router 4 (1.1.1.4): VTEP
├── eth2: 10.1.1.10/30 → Router 1  
└── eth0: Bridged to VXLAN 10

VXLAN ID: 10
BGP AS: 1
OSPF Area: 0
EOF
        ;;
    4)
        cat << 'EOF'

