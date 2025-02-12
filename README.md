# rpi_huawei_inverter_bridge
A script to configure a Raspberry Pi as a network bridge for Huawei SUN2000 PV inverters, enabling NAT, static IPs, and port forwarding.

# Raspberry Pi Huawei SUN2000 Network Bridge

## Overview

This script configures a Raspberry Pi as a network bridge to enable communication between a home network and a Huawei SUN2000 inverter. It was specifically developed to facilitate the use of the Home Assistant Huawei Solar Integration, allowing the inverter to be accessed via its IP address through a network bridge.

## Use Case

This script helps connect a Huawei SUN2000 inverter to a home network using a Raspberry Pi as a network bridge. The goal is to allow Home Assistant Huawei Solar Integration to communicate with the inverter via its IP address.

If you’re looking for a reliable way to bridge your home network to the Huawei inverter network for monitoring and data logging in Home Assistant, this script provides a simple and effective solution.

## Features

✔ Optimized for Huawei SUN2000 PV inverters
✔ Automatic detection of available network interfaces with interactive configuration
✔ Automatic detection of Huawei SUN2000 SSID and user confirmation
✔ Automatic detection of home network gateway with user confirmation
✔ User-configurable DNS settings
✔ Setup of NAT and port forwarding for specific inverter communication ports
✔ Network configurations managed via NetworkManager (nmcli) and firewall rules via firewalld
✔ Persistent configurations with automatic reconnection
✔ Connection tests for quality assurance

## Requirements

•	Raspberry Pi running a Debian-based OS (e.g., Raspberry Pi OS)
•	Huawei SUN2000 inverter with Wi-Fi or Ethernet communication
•	Installed tools: NetworkManager, firewalld, nmcli (automatically installed if missing)
•	Root privileges for network configuration

## Installation and Usage

1. **Download the script**:
   ```bash
   wget https://github.com/Karo-X/rpi_huawei_inverter_bridge/blob/main/raspberry_pi_network_bridge.sh
   chmod +x raspberry_pi_huawei_sun_bridge.sh

2.	Run the script:
   sudo ./raspberry_pi_huawei_sun_bridge.sh

4.	Follow the prompts:
	•	Select the interface for your home network (e.g., eth0 or wlan0)
	•	Select the interface for the inverter network (e.g., wlan1)
	•	Automatically detects available SSIDs and asks if the detected SUN2000 SSID should be used
	•	Automatically detects the home gateway and allows the user to confirm or modify it
	•	Allows user-defined DNS servers

Test the connection
	•	At the end, the script automatically performs connection tests, including:
 		ping -c 4 192.168.200.1
		ping -c 4 192.168.1.1
		ping -c 4 8.8.8.8



----

## Example Configuration

Assumptions:
	•	Home network: (e.g.) eth0
	•	Gateway: (e.g.) 192.168.1.1
	•	Raspberry Pi IP: (e.g.) 192.168.1.222
	•	Huawei inverter network: (e.g) wlan1
	•	Gateway: 192.168.200.1
	•	Raspberry Pi IP: 192.168.200.3

Port Forwarding:
	•	Port 6607 is forwarded from the home network (eth0) to the Huawei inverter (wlan1).
 		sudo firewall-cmd --list-forward-ports

----

## Troubleshooting

1.	No internet connection:
	•	Verify the home network gateway configuration (e.g. 192.168.1.1).
	•	Check the routing table: ip route
		Restart the firewall service if needed: sudo systemctl restart firewalld

3.	Inverter not reachable:
	•	Ensure the inverter SSID is visible: nmcli device wifi list | grep SUN2000
  	•	Restart the NetworkManager: sudo systemctl restart NetworkManager

5.	Ping tests fail:
	•	Check NetworkManager connections: nmcli device status

----

Contributions

Contributions and suggestions are welcome! Open an issue or submit a pull request to improve the script.
