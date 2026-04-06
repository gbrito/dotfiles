if [ -z "${WAYLAND_DISPLAY}" ] && [ "${XDG_VTNR}" -eq 1 ]; then
    _sway_log_dir="$HOME/.local/log"
    mkdir -p "$_sway_log_dir"
    # Clean up sway logs older than 30 days
    find "$_sway_log_dir" -name 'sway-*.log' -mtime +30 -delete 2>/dev/null
    XDG_CURRENT_DESKTOP=sway dbus-run-session sway 2>&1 | tee "$_sway_log_dir/sway-$(date +%Y%m%d-%H%M%S).log"
    unset _sway_log_dir
fi
