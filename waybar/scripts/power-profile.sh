#!/bin/bash

ICON="⚡"

cycle() {
    local current next
    current=$(powerprofilesctl get)
    case "$current" in
        power-saver) next="balanced" ;;
        balanced)    next="performance" ;;
        performance) next="power-saver" ;;
        *)           next="balanced" ;;
    esac
    powerprofilesctl set "$next"
}

render() {
    local current
    current=$(powerprofilesctl get)
    printf '{"text": "%s", "tooltip": "Power profile: %s", "class": "%s"}\n' \
        "$ICON" "$current" "$current"
}

case "${1:-}" in
    toggle) cycle ;;
    *)      render ;;
esac
