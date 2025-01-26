# rpi_huawei_inverter_bridge
A script to configure a Raspberry Pi as a network bridge for Huawei SUN2000 PV inverters, including NAT, static IPs, and port forwarding.

# Raspberry Pi Huawei SUN2000 Network Bridge

## Overview

This script configures a Raspberry Pi as a network bridge to enable communication between a home network and a **Huawei SUN2000 inverter**. It was specifically developed to facilitate the use of the [Home Assistant Huawei Solar Integration](https://github.com/wlcrs/huawei_solar), allowing the inverter to be accessed via its IP address through a network bridge.

## Use Case

This script was created to solve the challenge of connecting a **Huawei SUN2000 inverter** to a home network using a Raspberry Pi as a bridge. The main goal was to enable the use of the [Huawei Solar Integration for Home Assistant](https://github.com/wlcrs/huawei_solar), which requires network access to the inverter's IP address.

If you're looking for a reliable way to bridge your home network to the Huawei inverter network for monitoring and data logging in Home Assistant, this script provides a simple and effective solution.

---

## Features

	•	Optimized for Huawei SUN2000 PV inverters.
	•	Automatic detection of network interfaces with interactive configuration.
	•	Setup of NAT and port forwarding for specific inverter communication ports.
	•	Persistent configurations stored in /etc/dhcpcd.conf and /etc/iptables/rules.v4.
	•	Connection tests for quality assurance.

---

## Requirements

- Raspberry Pi running a Debian-based OS (e.g., Raspberry Pi OS).
- Huawei SUN2000 inverter with Wi-Fi or Ethernet communication.
- Installed tools: `iptables`, `dhcpcd`, `wpa_supplicant` (automatically installed if missing).
- Root privileges for network configuration.

---

## Installation and Usage

1. **Download the script**:
   ```bash
   wget https://github.com/Karo-X/rpi_huawei_sun_bridge/raspberry_pi_huawei_sun_bridge.sh
   chmod +x raspberry_pi_huawei_sun_bridge.sh

2.	Run the script:
   sudo ./raspberry_pi_huawei_sun_bridge.sh

3.	Follow the prompts:
	•	Select the interface for your home network (e.g., eth0).
	•	Select the interface for the inverter network (e.g., wlan1).
	•	Confirm or adjust the automatically detected IP and gateway settings.

5.	Test the connection:
	•	At the end, the script will run ping tests to ensure connectivity.

----

Example Configuration

Assumptions:
	•	Home network: (e.g.) eth0
	•	Gateway: (e.g.) 192.168.1.1
	•	Raspberry Pi IP: (e.g.) 192.168.1.222
	•	Huawei inverter network: (e.g) wlan1
	•	Gateway: 192.168.200.1
	•	Raspberry Pi IP: 192.168.200.3

Port Forwarding:
	•	Port 6607 is forwarded from the home network (eth0) to the Huawei inverter (wlan1).

----

Troubleshooting

1.	No internet connection:
	•	Verify the home network gateway configuration (e.g. 192.168.1.1).
	•	Check the routing table: ip route

2.	Inverter not reachable:
	•	Ensure the inverter SSID is visible: sudo iwlist wlan1 scan

3.	Ping tests fail:
	•	Verify the iptables rules: sudo iptables -t nat -L -n -v

----

Contributions

Contributions and suggestions are welcome! Open an issue or submit a pull request to improve the script.
