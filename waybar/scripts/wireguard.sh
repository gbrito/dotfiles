#!/usr/bin/env bash

set -u

readonly PROFILES_FILE="${XDG_CONFIG_HOME:-${HOME}/.config}/waybar/wireguard-profiles"
readonly ICON_CONNECTED=$'\uf023'
readonly ICON_DISCONNECTED=$'\uf09c'

declare -a profiles=()
load_error=""

load_profiles() {
    local profile

    profiles=()
    load_error=""

    if [[ ! -r "${PROFILES_FILE}" ]]; then
        load_error="Profile list not found: ${PROFILES_FILE}"
        return 1
    fi

    while IFS= read -r profile || [[ -n "${profile}" ]]; do
        profile=${profile%%#*}
        profile=${profile#"${profile%%[![:space:]]*}"}
        profile=${profile%"${profile##*[![:space:]]}"}
        [[ -n "${profile}" ]] || continue

        if [[ ! "${profile}" =~ ^[A-Za-z0-9_=+.-]{1,15}$ ]]; then
            load_error="Invalid WireGuard interface name: ${profile}"
            return 1
        fi
        profiles+=("${profile}")
    done < "${PROFILES_FILE}"

    if (( ${#profiles[@]} == 0 )); then
        load_error="No WireGuard profiles configured in ${PROFILES_FILE}"
        return 1
    fi
}

unit_state() {
    local profile=$1
    local active_state

    active_state=$(systemctl show "wg-quick@${profile}.service" \
        --property=ActiveState --value 2>/dev/null) || active_state="unknown"

    if [[ "${active_state}" == "active" ]]; then
        if ip link show dev "${profile}" >/dev/null 2>&1; then
            printf 'connected\n'
        else
            printf 'broken\n'
        fi
    elif [[ "${active_state}" == "inactive" ]] && ip link show dev "${profile}" >/dev/null 2>&1; then
        printf 'unmanaged\n'
    else
        printf '%s\n' "${active_state}"
    fi
}

profile_addresses() {
    local profile=$1

    ip -brief address show dev "${profile}" 2>/dev/null |
        awk '{ for (i = 3; i <= NF; i++) printf "%s%s", (i == 3 ? "" : ", "), $i }'
}

render_error() {
    jq --compact-output --null-input \
        --arg text "${ICON_DISCONNECTED}" \
        --arg tooltip "$1" \
        '{text: $text, tooltip: $tooltip, class: "error"}'
}

render() {
    local profile state addresses label
    local connected_count=0
    local pending_count=0
    local error_count=0
    local tooltip="WireGuard"
    local text class
    local -a connected_profiles=()

    if ! load_profiles; then
        render_error "${load_error}"
        return
    fi

    for profile in "${profiles[@]}"; do
        state=$(unit_state "${profile}")
        addresses=""

        case "${state}" in
            connected)
                label="connected"
                addresses=$(profile_addresses "${profile}")
                ((connected_count++))
                connected_profiles+=("${profile}")
                ;;
            activating)
                label="connecting"
                ((pending_count++))
                ;;
            deactivating)
                label="disconnecting"
                ((pending_count++))
                ;;
            failed)
                label="service failed"
                ((error_count++))
                ;;
            broken)
                label="service active, interface missing"
                ((error_count++))
                ;;
            unmanaged)
                label="up outside systemd"
                addresses=$(profile_addresses "${profile}")
                ((error_count++))
                ;;
            *)
                label="disconnected"
                ;;
        esac

        tooltip+=$'\n'"${profile}: ${label}"
        [[ -z "${addresses}" ]] || tooltip+=" (${addresses})"
    done

    tooltip+=$'\n\nLeft click: manage profiles\nRight click: connection details'

    if (( connected_count == 1 )); then
        text="${ICON_CONNECTED} ${connected_profiles[0]}"
    elif (( connected_count > 1 )); then
        text="${ICON_CONNECTED} ${connected_count}"
    else
        text="${ICON_DISCONNECTED}"
    fi

    if (( error_count > 0 )); then
        class="error"
    elif (( pending_count > 0 )); then
        class="connecting"
    elif (( connected_count > 0 )); then
        class="connected"
    else
        class="disconnected"
    fi

    jq --compact-output --null-input \
        --arg text "${text}" \
        --arg tooltip "${tooltip}" \
        --arg class "${class}" \
        '{text: $text, tooltip: $tooltip, class: $class}'
}

toggle_profile() {
    local profile=$1
    local state verb output

    state=$(unit_state "${profile}")
    case "${state}" in
        connected|activating)
            verb="stop"
            ;;
        deactivating)
            notify-send "WireGuard: ${profile}" "The profile is already disconnecting."
            return
            ;;
        broken)
            verb="restart"
            ;;
        unmanaged)
            notify-send -u critical "WireGuard: ${profile}" \
                "The interface was started outside systemd. Run: sudo wg-quick down ${profile}"
            return
            ;;
        *)
            verb="start"
            ;;
    esac

    if ! output=$(systemctl "${verb}" "wg-quick@${profile}.service" 2>&1); then
        notify-send -u critical "WireGuard: ${profile}" \
            "${output:-Failed to ${verb} the profile.}"
    fi
}

show_menu() {
    local profile state label choice
    local -a rows=()

    if ! load_profiles; then
        notify-send -u critical "WireGuard" "${load_error}"
        return
    fi

    for profile in "${profiles[@]}"; do
        state=$(unit_state "${profile}")
        case "${state}" in
            connected) label="connected" ;;
            activating) label="connecting" ;;
            deactivating) label="disconnecting" ;;
            failed) label="failed" ;;
            broken) label="active, interface missing" ;;
            unmanaged) label="up outside systemd" ;;
            *) label="disconnected" ;;
        esac
        rows+=("${profile}    ${label}")
    done

    if ! choice=$(printf '%s\n' "${rows[@]}" |
        rofi -dmenu -i -no-custom -format i -p "WireGuard"); then
        return
    fi
    [[ "${choice}" =~ ^[0-9]+$ ]] || return

    toggle_profile "${profiles[choice]}"
}

show_details() {
    setsid -f foot --app-id=wireguard-status --title="WireGuard status" \
        -e bash -c 'pkexec /usr/bin/wg show; result=$?; printf "\nPress Enter to close..."; read -r; exit "${result}"' \
        </dev/null >/dev/null 2>&1
}

case "${1:-render}" in
    menu) show_menu ;;
    status) show_details ;;
    render) render ;;
    *)
        printf 'Usage: %s [render|menu|status]\n' "${0##*/}" >&2
        exit 2
        ;;
esac
