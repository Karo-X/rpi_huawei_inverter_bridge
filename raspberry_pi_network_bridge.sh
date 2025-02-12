#!/bin/bash

echo "-------------------------------"
echo "Raspberry Pi Huawei SUN2000 Network Bridge Setup"
echo "-------------------------------"

# Network interface detection
echo "Detecting available network interfaces..."
interfaces=$(ls /sys/class/net | grep -v "lo")
echo "Detected network interfaces:"
echo "$interfaces"

# User input for interfaces
echo "Which interface connects to the home network (e.g., eth0 or wlan0)?"
read -rp "Home network interface: " HOME_INTERFACE

echo "Which interface connects to the Huawei SUN2000 inverter (e.g., wlan1)?"
read -rp "Huawei inverter interface: " INVERTER_INTERFACE

# Scan for available SSIDs matching SUN2000
echo "Scanning for Huawei SUN2000 inverter..."
SUN2000_SSID=$(nmcli device wifi list | grep -o 'SUN2000-[^ ]*' | head -n 1)
if [ -z "$SUN2000_SSID" ]; then
    echo "No Huawei SUN2000 inverter found. Please enter the SSID manually:"
    read -rp "Huawei SUN2000 SSID: " SUN2000_SSID
else
    echo "Found Huawei SUN2000 SSID: $SUN2000_SSID"
    read -rp "Use this SSID? (y/n): " CONFIRM_SSID
    if [ "$CONFIRM_SSID" != "y" ]; then
        read -rp "Enter the correct SSID: " SUN2000_SSID
    fi
fi

SUN2000_PASSWORD="Changeme"

# Detect home gateway automatically or ask user
default_gateway=$(ip route | grep default | awk '{print $3}')
echo "Detected home network gateway: $default_gateway"
read -rp "Confirm home gateway IP (press enter to keep $default_gateway or enter new one): " HOME_GATEWAY
HOME_GATEWAY=${HOME_GATEWAY:-$default_gateway}

# Ask for DNS servers or use defaults
default_dns="8.8.8.8 1.1.1.1"
echo "Default DNS servers: $default_dns"
read -rp "Confirm DNS servers (press enter to keep or enter new ones separated by spaces): " DNS_SERVERS
DNS_SERVERS=${DNS_SERVERS:-$default_dns}

LOCAL_IP="192.168.200.3/24"
LOCAL_ROUTER="192.168.200.1"

# Confirmation
echo "For the Huawei SUN2000 inverter, the following configuration will be applied:"
echo "- SSID: $SUN2000_SSID"
echo "- Local IP: $LOCAL_IP"
echo "- Gateway: $LOCAL_ROUTER"
echo "- Home Gateway: $HOME_GATEWAY"
echo "- DNS Servers: $DNS_SERVERS"
read -rp "Confirm the configuration (y/n): " CONFIRM
if [ "$CONFIRM" != "y" ]; then
    echo "Aborted. Please re-run the script with correct values."
    exit 1
fi

# Enable NetworkManager
sudo systemctl enable NetworkManager
sudo systemctl start NetworkManager

# Configure home network
echo "Configuring home network on $HOME_INTERFACE..."
sudo nmcli connection modify "$HOME_INTERFACE" ipv4.method auto

# Configure inverter network
echo "Configuring Huawei SUN2000 inverter connection on $INVERTER_INTERFACE..."
sudo nmcli connection delete "Huawei_Inverter" &>/dev/null
sudo nmcli connection add type wifi ifname "$INVERTER_INTERFACE" con-name "Huawei_Inverter" ssid "$SUN2000_SSID"
sudo nmcli connection modify "Huawei_Inverter" wifi-sec.key-mgmt wpa-psk
sudo nmcli connection modify "Huawei_Inverter" wifi-sec.psk "$SUN2000_PASSWORD"
sudo nmcli connection modify "Huawei_Inverter" ipv4.method manual ipv4.addresses "$LOCAL_IP"
sudo nmcli connection modify "Huawei_Inverter" ipv4.gateway "$LOCAL_ROUTER"
sudo nmcli connection modify "Huawei_Inverter" ipv4.dns "$DNS_SERVERS"

# Bring up the connection
echo "Activating Huawei inverter connection..."
sudo nmcli connection up "Huawei_Inverter"

# Enable IP forwarding
echo "Enabling IP forwarding..."
echo 1 | sudo tee /proc/sys/net/ipv4/ip_forward
sudo nmcli connection modify "$HOME_INTERFACE" ipv4.never-default yes

# Configure NAT and port forwarding using firewalld
echo "Configuring NAT and port forwarding for Huawei SUN2000..."
sudo firewall-cmd --permanent --add-masquerade
sudo firewall-cmd --permanent --add-forward-port=port=6607:proto=tcp:toaddr=$LOCAL_ROUTER
echo "Reloading firewall rules..."
sudo firewall-cmd --reload

# Test connection
echo "Testing connectivity..."
ping -c 4 "$LOCAL_ROUTER"
ping -c 4 "$HOME_GATEWAY"
ping -c 4 "8.8.8.8"

echo "Setup completed. Your Raspberry Pi is now configured as a network bridge for Huawei SUN2000."
