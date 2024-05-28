#!/bin/bash

# get_media_status_icon() {
#     if playerctl status &> /dev/null; then
#         status=$(playerctl status)
#         if [[ $status == "Playing" ]]; then
#             echo ' ▶ '
#         fi
#     fi
# }

# # Function to get media song name and player status
# get_media_status() {
#     if playerctl status &> /dev/null; then
#         artist=$(playerctl metadata artist)
#         song=$(playerctl metadata title)
#         echo "$song • $artist"
#     else
#         echo "No media"
#     fi
# }

# Function to get active workspaces
get_workspaces() {
    swaymsg -t get_workspaces | jq -r '.[] | select(.focused) | .name'
}

# Function to get current opened window
get_current_window() {
    swaymsg -t get_tree | jq -r '.. | select(.focused? and .type?) | .name'
}

# Function to get Pipewire default sink audio level
get_audio_level() {
    # Check if sink is muted
    is_muted=$(pactl get-sink-mute @DEFAULT_SINK@ | grep -oP 'yes')
    volume=$(pactl get-sink-volume @DEFAULT_SINK@ | grep -oP '\d+%' | head -1)
    if [[ "$is_muted" == "yes" ]]; then
        echo "  (${volume})"
    else
        echo "$volume"
    fi
}
# Function to check connected audio devices and display corresponding icon
get_audio_device_icon() {
    # Check for Bluetooth
    if pactl list sinks | grep -q 'Name: bluez_output'; then
        echo 'ᛒ' # Bluetooth icon
    # Check for Headphones
    elif pactl list sinks | grep -q 'Active Port: analog-output-headphones'; then
        echo '☊' # Headphones icon
    # Default to Speakers
    elif pactl list sinks | grep -q 'Active Port: analog-output-speaker'; then
        echo '🕨' # Speaker icon
    fi
}

# Function to get the current keyboard layout (X11 warning)
# get_keyboard_layout() {
    # setxkbmap -query | grep layout | awk '{print $2}' | cut -d ',' -f 1
# }

# Function to get the current keyboard layout
get_keyboard_layout() {
    swaymsg -t get_inputs | jq -r '.[] | select(.identifier == "1:1:AT_Translated_Set_2_keyboard") | .xkb_active_layout_name' | head -n 1
}

# Function to get network status
get_network_status() {
    wifi_status=$(iw dev wlp1s0 link)
    eth_status=$(ip a | grep "enp3s0f3u1u2u4")
    if [ "$eth_status" != "" ]; then
        ip_addr=$(echo "$eth_status" | grep 'inet ' | awk '{print $2}')
        speed=$(cat /sys/class/net/enp3s0f3u1u2u4/speed)
        echo "Ethernet: $ip_addr (${speed}Mbps)"
    elif [ "$wifi_status" != "Not connected." ]; then
        essid=$(echo "$wifi_status" | grep 'SSID' | awk '{print $2}')
        signal=$(echo "$wifi_status" | grep 'signal' | awk '{print $2 " " $3}')
        echo "WiFi: $essid"
    else
        echo "No internet"
    fi
}

# Function to get brightness level
get_brightness_level() {
    brightnessctl g | awk '{printf "%.0f", ($1/255)*100}'
}

# Function to get battery level
get_battery_level() {
    if [ $(cat /sys/class/power_supply/BAT1/status) != "Discharging" ]; then
        echo "🗲$(cat /sys/class/power_supply/BAT1/capacity)%"
    else
        echo "$(cat /sys/class/power_supply/BAT1/capacity)%"
    fi
}

# Function to get clock in 24h mode
get_clock() {
    date '+%H:%M'
}


# Main loop to update swaybar
while true; do
    # Get current values
    #left="$(get_media_status_icon)$(get_media_status)"
    right=" $(get_keyboard_layout)  |  $(get_network_status)  |  $(get_audio_device_icon) : $(get_audio_level)  |  ☼ $(get_brightness_level)%  |     $(get_battery_level)  |  $(get_clock)"
    
    echo "$right  "
done

