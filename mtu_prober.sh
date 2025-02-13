#!/bin/bash

RED='\e[31m'
GREEN='\e[32m'
YELLOW='\e[33m'
CYAN='\e[36m'
NC='\e[0m' # No Color

interface=""
start_mtu=1280
peer_address=""

usage() {
  echo -e "${CYAN}Usage: $0 -i <interface> -s <start_mtu> -p <peer_address${NC}"
  echo -e "  ${CYAN}-i <interface> | --interface <interface>:${NC} WireGuard interface name (e.g., wg0)"
  echo -e "  ${CYAN}-s <start_mtu> | --start-mtu <start_mtu>:${NC} Starting MTU value (e.g., 1280)"
  echo -e "  ${CYAN}-p <peer_address> | --peer <peer_address>:${NC} Peer IP address or hostname to ping (IPv4 or IPv6)"
  exit 1
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -i|--interface)
      interface="$2"
      shift 2
      ;;
    -s|--start-mtu)
      start_mtu="$2"
      shift 2
      ;;
    -p|--peer)
      peer_address="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo -e "${RED}Unknown option: $1${NC}"
      usage
      exit 1
      ;;
  esac
done

if [ -z "$interface" ] || [ -z "$peer_address" ]; then
  echo -e "${RED}Error: Missing interface name or peer address.${NC}"
  usage
  exit 1
fi

if ! [[ "$start_mtu" =~ ^[0-9]+$ ]]; then
  echo -e "${RED}Error: Starting MTU must be a number.${NC}"
  usage
  exit 1
fi

min_mtu=$start_mtu
max_mtu=9000  # Jumbo Frame
found_mtu=0

echo -e "${GREEN}Starting MTU discovery on interface '${CYAN}$interface${NC}' to peer '${CYAN}$peer_address${NC}'...${NC}"

while [ "$min_mtu" -le "$max_mtu" ]; do
  current_mtu=$(( (min_mtu + max_mtu) / 2 ))
  printf "${YELLOW}Testing MTU: %-5d (Range: %d - %d)... ${NC}" "$current_mtu" "$min_mtu" "$max_mtu"
  if [[ "$peer_address" == *":"* ]]; then
    header_size=48  # 40 (IPv6 header) + 8 (ICMPv6 header)
  else
    header_size=28  # 20 (IPv6 header) + 8 (ICMP header)
  fi

  ping -c 1 -s $((current_mtu - header_size)) -M probe -W 1 -I "$interface" "$peer_address" > /dev/null 2>&1

  if [ $? -eq 0 ]; then
    echo -e "${GREEN}Success${NC}"
    found_mtu=$current_mtu
    min_mtu=$((current_mtu + 1))
  else
    echo -e "${RED}Fail${NC}"
    max_mtu=$((current_mtu - 1))
  fi
done

if [ "$found_mtu" -gt 0 ]; then
  echo -e ""
  echo -e "${GREEN}Maximum MTU for interface '${CYAN}$interface${NC}' to peer '${CYAN}$peer_address${NC}' is: ${CYAN}$found_mtu${NC}${NC}"

  if [[ "$peer_address" == *":"* ]]; then
    header_size=48  # 40 (IPv6 header) + 8 (ICMPv6 header)
  else
    header_size=28  # 20 (IPv6 header) + 8 (ICMP header)
  fi

  max_mtu_ping_command="ping -c 1 -s $((found_mtu - header_size)) -M probe -W 1 -I \"$interface\" \"$peer_address\""
  max_mtu_plus_one_ping_command="ping -c 1 -s $((found_mtu + 1 - header_size)) -M probe -W 1 -I \"$interface\" \"$peer_address\""

  echo -e ""
  echo -e "${CYAN}To verify, run these commands:${NC}"
  echo -e "  ${GREEN}# Test maximum MTU (should succeed):${NC}"
  echo -e "  ${YELLOW}$max_mtu_ping_command${NC}"
  echo -e ""
  echo -e "  ${RED}# Test MTU + 1 (should fail, likely with timeout or fragmentation needed, but probe will still send):${NC}"
  echo -e "  ${YELLOW}$max_mtu_plus_one_ping_command${NC}"
else
  echo -e ""
  echo -e "${RED}Could not determine maximum MTU. Check connectivity and parameters.${NC}"
  exit 1
fi

exit 0