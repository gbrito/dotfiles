if [ -z "${WAYLAND_DISPLAY}" ] && [ "${XDG_VTNR}" -eq 1 ]; then
    XDG_CURRENT_DESKTOP=sway dbus-run-session sway
fi
