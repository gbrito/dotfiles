#!/bin/bash

ICON_BT_ON=$'\U000F00AF'      # 󰂯 bluetooth connected
ICON_BT_OFF=$'\U000F00B2'     # 󰂲 bluetooth off
ICON_BATT_LOW=$'\U000F0083'   # 󰂃 battery alert

LOW_BATTERY_THRESHOLD=30
BTCTL_TIMEOUT=3
STATE_FILE="${XDG_RUNTIME_DIR:-/tmp}/waybar-bluetooth-lowbatt"

# Notify once when a device drops below the threshold
notify_low_battery() {
    local name="$1"
    local battery="$2"

    setsid -f notify-send -u critical -i battery-caution \
        "Bluetooth battery low" "$name is at ${battery}% — time to charge." \
        < /dev/null > /dev/null 2>&1
}

get_bluetooth_status() {
    local powered
    powered=$(echo -e 'show\nquit' | timeout "$BTCTL_TIMEOUT" bluetoothctl 2>&1 | grep -i "Powered:" | awk '{print $2}')

    if [[ "$powered" != "yes" ]]; then
        : > "$STATE_FILE"
        printf '{"text": "%s", "tooltip": "Bluetooth is off", "class": "off"}\n' "$ICON_BT_OFF"
        exit 0
    fi

    local connected_devices
    connected_devices=$(echo -e 'devices Connected\nquit' | timeout "$BTCTL_TIMEOUT" bluetoothctl 2>&1 | grep "^Device")

    if [[ -z "$connected_devices" ]]; then
        : > "$STATE_FILE"
        printf '{"text": "%s", "tooltip": "No devices connected", "class": "disconnected"}\n' "$ICON_BT_ON"
        exit 0
    fi

    local tooltip=""
    local first=true
    local lowest_battery=-1
    local new_state=""

    touch "$STATE_FILE"

    while IFS= read -r line; do
        if [[ -z "$line" ]]; then
            continue
        fi

        local mac
        local name
        mac=$(echo "$line" | awk '{print $2}')
        name=$(echo "$line" | cut -d' ' -f3-)

        local device_info
        device_info=$(timeout "$BTCTL_TIMEOUT" bluetoothctl info "$mac" 2>/dev/null)

        local battery
        battery=$(echo "$device_info" | grep -i "Battery Percentage" | grep -oP '0x[0-9a-fA-F]+ \(\K[0-9]+')

        if [[ "$first" == true ]]; then
            first=false
        else
            tooltip+="\\n"
        fi

        if [[ -n "$battery" ]]; then
            if (( battery < LOW_BATTERY_THRESHOLD )); then
                tooltip+="$name: ${battery}% ⚠"
                local key
                key=$(echo "$name" | tr -c '[:alnum:]' '_')
                if ! grep -qxF "$key" "$STATE_FILE"; then
                    notify_low_battery "$name" "$battery"
                fi
                new_state+="$key"$'\n'
                if (( lowest_battery == -1 || battery < lowest_battery )); then
                    lowest_battery="$battery"
                fi
            else
                tooltip+="$name: ${battery}%"
            fi
        else
            tooltip+="$name: Connected"
        fi
    done <<< "$connected_devices"

    # Keep only devices that are still connected and low, so a device that
    # disconnects (or recovers) gets notified again on its next low episode.
    printf '%s' "$new_state" > "$STATE_FILE"

    tooltip="${tooltip//\"/\\\"}"

    if (( lowest_battery >= 0 )); then
        printf '{"text": "%s %d%%", "tooltip": "%s", "class": "low-battery"}\n' \
            "$ICON_BATT_LOW" "$lowest_battery" "$tooltip"
    else
        printf '{"text": "%s", "tooltip": "%s", "class": "connected"}\n' "$ICON_BT_ON" "$tooltip"
    fi
}

get_bluetooth_status
