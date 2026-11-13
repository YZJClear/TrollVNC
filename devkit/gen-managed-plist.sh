#!/usr/bin/env bash
set -euo pipefail

# Generate prefs/TrollVNCPrefs/Resources/Managed.plist from environment variables.
PLIST="prefs/TrollVNCPrefs/Resources/Managed.plist"
mkdir -p "$(dirname "$PLIST")"

cat > "$PLIST" <<'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
EOF

add_bool() {
  local k="$1" v="${2:-}"
  echo "  <key>$k</key>" >> "$PLIST"
  if [[ "$v" == "true" || "$v" == "True" || "$v" == "TRUE" ]]; then
    echo "  <true/>" >> "$PLIST"
  else
    echo "  <false/>" >> "$PLIST"
  fi
}

add_str() {
  local k="$1" v="${2:-}"
  if [[ -n "$v" ]]; then
    v="${v//&/\&amp;}"; v="${v//</\&lt;}"; v="${v//>/\&gt;}"
    echo "  <key>$k</key>" >> "$PLIST"
    echo "  <string>$v</string>" >> "$PLIST"
  fi
}

add_int() {
  local k="$1" v="${2:-}"
  if [[ -n "$v" ]]; then
    echo "  <key>$k</key>" >> "$PLIST"
    echo "  <integer>$v</integer>" >> "$PLIST"
  fi
}

add_real() {
  local k="$1" v="${2:-}"
  if [[ -n "$v" ]]; then
    echo "  <key>$k</key>" >> "$PLIST"
    echo "  <real>$v</real>" >> "$PLIST"
  fi
}

add_launch_at_login() {
  local v="${1:-}"
  if [[ -z "$v" ]]; then
    return
  fi
  echo "  <key>LaunchAtLogin</key>" >> "$PLIST"
  case "$v" in
    true|True|TRUE) echo "  <true/>" >> "$PLIST" ;;
    false|False|FALSE) echo "  <false/>" >> "$PLIST" ;;
    *) add_str LaunchAtLogin "$v" ;;
  esac
}

# Booleans
add_bool Enabled               "${TVNC_ENABLED:-}"
add_bool ClipboardEnabled      "${TVNC_CLIPBOARD_ENABLED:-}"
add_bool ViewOnly              "${TVNC_VIEW_ONLY:-}"
add_bool SingleNotifEnabled    "${TVNC_SINGLE_NOTIF_ENABLED:-}"
add_bool ClientNotifsEnabled   "${TVNC_CLIENT_NOTIFS_ENABLED:-}"
add_bool OrientationSync       "${TVNC_ORIENTATION_SYNC:-}"
add_bool OrientationPadFix     "${TVNC_ORIENTATION_PAD_FIX:-}"
add_bool NaturalScroll         "${TVNC_NATURAL_SCROLL:-}"
add_bool AutoAssistEnabled     "${TVNC_AUTO_ASSIST_ENABLED:-}"
add_bool ServerCursor          "${TVNC_SERVER_CURSOR:-}"
add_bool AsyncSwap             "${TVNC_ASYNC_SWAP:-}"
add_bool BonjourEnabled        "${TVNC_BONJOUR_ENABLED:-}"
add_bool KeyLogging            "${TVNC_KEY_LOGGING:-}"

# Strings
add_str DesktopName            "${TVNC_DESKTOP_NAME:-}"
add_str FrameRateSpec          "${TVNC_FRAME_RATE_SPEC:-}"
add_str WheelTuning            "${TVNC_WHEEL_TUNING:-}"
add_str HttpDir                "${TVNC_HTTP_DIR:-}"
add_str SslCertFile            "${TVNC_SSL_CERT_FILE:-}"
add_str SslKeyFile             "${TVNC_SSL_KEY_FILE:-}"
add_str ReverseMode            "${TVNC_REVERSE_MODE:-}"
add_str ReverseSocket          "${TVNC_REVERSE_SOCKET:-}"
add_str FullPassword           "${TVNC_FULL_PASSWORD:-}"
add_str ViewOnlyPassword       "${TVNC_VIEWONLY_PASSWORD:-}"
add_str ModifierMap            "${TVNC_MODIFIER_MAP:-}"

# Integers
add_int Port                           "${TVNC_PORT:-}"
add_int MaxInflight                    "${TVNC_MAX_INFLIGHT:-}"
add_int TileSize                       "${TVNC_TILE_SIZE:-}"
add_int FullscreenThresholdPercent     "${TVNC_FULLSCREEN_THRESHOLD_PERCENT:-}"
add_int MaxRects                       "${TVNC_MAX_RECTS:-}"
add_int HttpPort                       "${TVNC_HTTP_PORT:-}"
add_int ReverseRepeaterID              "${TVNC_REVERSE_REPEATER_ID:-}"

# Reals
add_real KeepAliveSec         "${TVNC_KEEPALIVE_SEC:-}"
add_real Scale                "${TVNC_SCALE:-}"
add_real DeferWindowSec       "${TVNC_DEFER_WINDOW_SEC:-}"
add_real WheelStepPx          "${TVNC_WHEEL_STEP_PX:-}"

# Login behavior (true/false or an app bundle identifier)
add_launch_at_login "${TVNC_LAUNCH_AT_LOGIN:-}"

cat >> "$PLIST" <<'EOF'
</dict>
</plist>
EOF

plutil -convert xml1 "$PLIST"
echo "Managed configuration generated at $PLIST"
