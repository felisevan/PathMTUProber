# PathMTUProber

**PathMTUProber** is a Bash script used for probing the Path Maximum Transmission Unit (Path MTU) of a network path.

## 🚀 Features

* ✅ **IPv4 Support**:  Comprehensive support for IPv4 network environments.
* ✅ **IPv6 Support**:  Perfect support for IPv6 network environments.
* ✅ **Automatic IP Version Detection**: No need to manually specify the IP version, the script automatically detects the IP version (IPv4 or IPv6) of the target address.

## 🛠️ Usage

### Prerequisites

* Ensure you have the `ping` command installed on your system.
* The script needs to be run in a Bash environment.

### Running the Script

In your terminal, use the following command to run the `mtu-finder.sh` script:

```bash
./mtu-finder.sh -i <interface> -s <start_mtu> -p <peer_address>
```

### Parameter Description

* `-i <interface>` or `--interface <interface>`:  Specifies the **network interface name** used to send probe packets, such as `eth0`, `wlan0`, or `wg0` (WireGuard interface).
* `-s <start_mtu>` or `--start-mtu <start_mtu>`:  Specifies the **starting MTU value**. The script will start probing from this value. It is recommended to start with a smaller value, such as `1280` (the minimum MTU for IPv6).
* `-p <peer_address>` or `--peer <peer_address>`:  Specifies the **target IP address or hostname**. The script will send probe packets to this address. Supports IPv4 addresses, IPv6 addresses, or domain names.

### Usage Examples

**1. Probing the Path MTU to `ipv4.google.com` using the WireGuard interface `wg0`, starting MTU is 1280:**

```bash
./mtu-finder.sh -i wg0 -s 1280 -p ipv4.google.com
```

**2. Probing the Path MTU to the IPv6 address `2404:6800::8` using the network interface `eth0`, starting MTU is 1400:**

```bash
./mtu-finder.sh -i eth0 -s 1400 -p 2404:6800::8
```

## ⚙️ How it Works (Briefly)

The PathMTUProber script probes the Path MTU by sending ICMP packets with the "Don't Fragment (DF)" flag set.

1. The script starts with the specified starting MTU and gradually increases the MTU value.
2. Each time a probe packet is sent, if a router on the network path does not support the current MTU size and needs to fragment it, it will return an "ICMP Fragmentation Needed" error message because the DF flag is set.
3. The script uses the presence or absence of error messages to determine if the current MTU is too large and employs a binary search strategy to quickly find the maximum MTU value for the network path.

## 💡 Use Cases

* **WireGuard and other VPN Environments:**  Path MTU setting is crucial when configuring VPNs like WireGuard. Incorrect MTU settings can lead to unstable connections or performance degradation.
* **Network Performance Optimization:** Understanding the Path MTU of your network path can help you optimize network configurations, avoid unnecessary fragmentation, and improve network transmission efficiency.
* **Network Troubleshooting:** When network connection issues arise, probing the Path MTU can help you diagnose whether problems are caused by improper MTU settings.

## 📄 License

This project is licensed under the **AGPLv3** License.
