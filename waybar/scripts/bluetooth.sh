#!/bin/bash

ICON_BT_ON=$'\U000F00AF'      # 󰂯 bluetooth connected
ICON_BT_OFF=$'\U000F00B2'     # 󰂲 bluetooth off

get_bluetooth_status() {
    local powered
    powered=$(bluetoothctl show 2>/dev/null | grep -i "Powered:" | awk '{print $2}')

    if [[ "$powered" != "yes" ]]; then
        printf '{"text": "%s", "tooltip": "Bluetooth is off", "class": "off"}\n' "$ICON_BT_OFF"
        exit 0
    fi

    local connected_devices
    connected_devices=$(bluetoothctl devices Connected 2>/dev/null)

    if [[ -z "$connected_devices" ]]; then
        printf '{"text": "%s", "tooltip": "No devices connected", "class": "disconnected"}\n' "$ICON_BT_ON"
        exit 0
    fi

    local tooltip=""
    local first=true

    while IFS= read -r line; do
        if [[ -z "$line" ]]; then
            continue
        fi

        local mac
        local name
        mac=$(echo "$line" | awk '{print $2}')
        name=$(echo "$line" | cut -d' ' -f3-)

        local device_info
        device_info=$(bluetoothctl info "$mac" 2>/dev/null)

        local battery
        battery=$(echo "$device_info" | grep -i "Battery Percentage" | grep -oP '0x[0-9a-fA-F]+ \(\K[0-9]+')

        if [[ "$first" == true ]]; then
            first=false
        else
            tooltip+="\\n"
        fi

        if [[ -n "$battery" ]]; then
            tooltip+="$name: ${battery}%"
        else
            tooltip+="$name: Connected"
        fi
    done <<< "$connected_devices"

    tooltip="${tooltip//\"/\\\"}"

    printf '{"text": "%s", "tooltip": "%s", "class": "connected"}\n' "$ICON_BT_ON" "$tooltip"
}

get_bluetooth_status
