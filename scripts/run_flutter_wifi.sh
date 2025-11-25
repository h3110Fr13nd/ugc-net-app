#!/bin/bash

# Flutter WiFi Debugging Script
# This script helps you connect to an Android device over WiFi for debugging

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Flutter WiFi Debugging Setup${NC}"
echo "=============================="

# Check if adb is available
if ! command -v adb &> /dev/null; then
    echo -e "${RED}Error: adb not found. Please install Android SDK Platform Tools.${NC}"
    exit 1
fi

# Function to connect to device
connect_wifi() {
    local device_ip=$1
    local port=${2:-5555}
    
    echo -e "${YELLOW}Connecting to $device_ip:$port...${NC}"
    adb connect "$device_ip:$port"
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ Connected successfully!${NC}"
        return 0
    else
        echo -e "${RED}✗ Connection failed${NC}"
        return 1
    fi
}

# Check if device IP is provided as argument
if [ -n "$1" ]; then
    DEVICE_IP=$1
else
    # Try to get IP from USB-connected device
    echo -e "${YELLOW}Checking for USB-connected devices...${NC}"
    USB_DEVICES=$(adb devices | grep -v "List" | grep "device$" | wc -l)
    
    if [ "$USB_DEVICES" -eq 0 ]; then
        echo -e "${RED}No USB devices found.${NC}"
        echo ""
        echo "Please provide device IP address:"
        echo "Usage: $0 <device-ip> [port]"
        echo "Example: $0 192.168.1.100"
        echo ""
        echo "To find your device IP:"
        echo "  1. On your Android device, go to Settings > About Phone > Status"
        echo "  2. Look for 'IP address' or 'Wi-Fi IP address'"
        echo "  Or run: adb shell ip addr show wlan0 | grep 'inet '"
        exit 1
    fi
    
    echo -e "${GREEN}Found $USB_DEVICES USB device(s)${NC}"
    
    # Enable TCP/IP mode on port 5555
    echo -e "${YELLOW}Enabling TCP/IP debugging on port 5555...${NC}"
    adb tcpip 5555
    
    # Wait for device to restart in TCP mode
    echo "Waiting for device to restart in TCP mode..."
    sleep 2
    
    # Get device IP address
    echo -e "${YELLOW}Getting device IP address...${NC}"
    DEVICE_IP=$(adb shell ip addr show wlan0 | grep 'inet ' | awk '{print $2}' | cut -d/ -f1 | tr -d '\r')
    
    if [ -z "$DEVICE_IP" ]; then
        echo -e "${RED}Could not determine device IP address.${NC}"
        echo "Please manually provide the IP address:"
        echo "Usage: $0 <device-ip>"
        exit 1
    fi
    
    echo -e "${GREEN}Device IP: $DEVICE_IP${NC}"
    
    # Disconnect USB (optional - user can do this manually)
    echo ""
    echo -e "${YELLOW}You can now disconnect the USB cable.${NC}"
    echo "Press Enter when ready to connect via WiFi..."
    read
fi

# Connect via WiFi
PORT=${2:-5555}
connect_wifi "$DEVICE_IP" "$PORT"

# List connected devices
echo ""
echo "Connected devices:"
adb devices

# Load environment variables
echo ""
echo -e "${YELLOW}Loading environment variables...${NC}"
if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | xargs)
    echo -e "${GREEN}✓ Loaded .env file${NC}"
else
    echo -e "${YELLOW}⚠ No .env file found, using defaults${NC}"
fi

# Set API_BASE_URL if not already set
if [ -z "$API_BASE_URL" ]; then
    API_BASE_URL="http://192.168.1.29:8000/api/v1"
    echo -e "${YELLOW}Using default API_BASE_URL: $API_BASE_URL${NC}"
fi

echo ""
echo -e "${GREEN}Running Flutter app with API_BASE_URL=$API_BASE_URL${NC}"
echo ""

# Run Flutter with environment variable
flutter run --dart-define="API_BASE_URL=$API_BASE_URL"

# Cleanup function
cleanup() {
    echo ""
    echo -e "${YELLOW}To disconnect WiFi debugging:${NC}"
    echo "  adb disconnect $DEVICE_IP:$PORT"
    echo ""
    echo -e "${YELLOW}To switch back to USB debugging:${NC}"
    echo "  adb usb"
}

trap cleanup EXIT
