```bash
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
echo "Which interface connects to the home network (e.g., eth0)?"
read -rp "Home network interface: " ETH_INTERFACE

echo "Which interface connects to the Huawei SUN2000 inverter (e.g., wlan1)?"
read -rp "Huawei inverter interface: " WLAN_INTERFACE

# Default configuration for Huawei SUN2000
HOME_GATEWAY="192.168.1.1"
LOCAL_IP="192.168.200.3"
LOCAL_ROUTER="192.168.200.1"

echo "For the Huawei SUN2000 inverter, the following configuration will be applied:"
echo "- Local IP: $LOCAL_IP"
echo "- Gateway: $LOCAL_ROUTER"
read -rp "Confirm the configuration for the inverter (y/n): " CONFIRM
if [ "$CONFIRM" != "y" ]; then
    echo "Aborted. Please re-run the script with correct values."
    exit 1
fi

# Set up static IP for the inverter interface
echo "Configuring static IP for $WLAN_INTERFACE..."
cat <<EOT >> /etc/dhcpcd.conf
interface $WLAN_INTERFACE
static ip_address=$LOCAL_IP/24
static routers=
static domain_name_servers=8.8.8.8 1.1.1.1
EOT

# Configure NAT and port forwarding for Huawei inverter
echo "Configuring NAT and port forwarding for Huawei SUN2000..."
sudo iptables -t nat -A POSTROUTING -o $WLAN_INTERFACE -j MASQUERADE
sudo iptables -A FORWARD -i $ETH_INTERFACE -o $WLAN_INTERFACE -j ACCEPT
sudo iptables -A FORWARD -i $WLAN_INTERFACE -o $ETH_INTERFACE -m state --state RELATED,ESTABLISHED -j ACCEPT
sudo iptables -t nat -A PREROUTING -i $ETH_INTERFACE -p tcp --dport 6607 -j DNAT --to-destination $LOCAL_ROUTER:6607
sudo iptables -A FORWARD -p tcp -d $LOCAL_ROUTER --dport 6607 -j ACCEPT

# Save NAT rules
sudo iptables-save | sudo tee /etc/iptables/rules.v4

# Test connection
echo "Testing connectivity..."
ping -c 4 $LOCAL_ROUTER
ping -c 4 $HOME_GATEWAY
ping -c 4 8.8.8.8

echo "Setup completed. Your Raspberry Pi is now configured as a network bridge for Huawei SUN2000."
