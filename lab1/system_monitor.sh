#!/usr/bin/env bash

# Purpose: Monitor system metrics (memory, CPU, disk, load) every 10 minutes
#          and save them to a CSV file system_report_YYYY-MM-DD.csv
# Adapted for macOS

SCRIPT_NAME=$(basename "$0")
PID_FILE="/tmp/${SCRIPT_NAME}.pid"
LOG_DIR="./logs"
INTERVAL=600   # 10 minutes in seconds

# Create log directory if it does not exist
mkdir -p "$LOG_DIR"

# Function to collect system metrics on macOS
get_metrics() {
    # Current timestamp
    timestamp=$(date +"%Y-%m-%d %H:%M:%S")

    # Memory usage (in MB)
    mem_total=$(sysctl -n hw.memsize)
    mem_total=$((mem_total / 1024 / 1024))  # convert bytes to MB

    free_mem_pages=$(vm_stat | awk '/free/ {print $3}' | sed 's/\.//')
    inactive_mem_pages=$(vm_stat | awk '/inactive/ {print $3}' | sed 's/\.//')
    page_size=$(vm_stat | awk '/page size of/ {print $8}')
    mem_free=$(( (free_mem_pages + inactive_mem_pages) * page_size / 1024 / 1024 ))

    mem_used_percent=$(awk "BEGIN {printf \"%.2f\", ($mem_total - $mem_free)/$mem_total * 100}")

    # CPU usage (sum of user + sys)
    cpu_used_percent=$(top -l 1 -n 0 | awk '/CPU usage:/ {print $3 + $5}')

    # Disk usage for root partition
    disk_used_percent=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')

    # Load average over 1 minute
	load_avg_1m=$(uptime | awk -F'load averages?: ' '{print $2}' | awk '{print $1}')

    # Format metrics as CSV line
    echo "${timestamp};${mem_total};${mem_free};${mem_used_percent};${cpu_used_percent};${disk_used_percent};${load_avg_1m}"
}

# Function to write metrics to CSV file
write_metrics() {
    csv_file="${LOG_DIR}/system_report_$(date +%F).csv"

    # Add CSV header if the file is new
    if [ ! -f "$csv_file" ]; then
        echo "timestamp;all_memory;free_memory;%memory_used;%cpu_used;%disk_used;load_average_1m" > "$csv_file"
    fi

    # Append the collected metrics
    get_metrics >> "$csv_file"
}

# Function to run the monitoring loop
run_monitor() {
    echo $$ > "$PID_FILE"
    while true; do
        write_metrics
        sleep "$INTERVAL"
    done
}

# Function to start the script in the background
start_script() {
    if [ -f "$PID_FILE" ]; then
        if ps -p "$(cat "$PID_FILE")" > /dev/null 2>&1; then
            echo "Error: script is already running (PID $(cat "$PID_FILE"))"
            exit 1
        else
            rm -f "$PID_FILE"
        fi
    fi

    # Start monitoring in background and save its PID
    nohup bash "$0" run > /dev/null 2>&1 &
    NEW_PID=$!
    echo "$NEW_PID" > "$PID_FILE"
    echo "Script started in background (PID $NEW_PID)."
}

# Function to stop the script
stop_script() {
    if [ ! -f "$PID_FILE" ]; then
        echo "Script is not running."
        exit 0
    fi

    PID=$(cat "$PID_FILE")
    if ps -p "$PID" > /dev/null 2>&1; then
        kill "$PID"
        rm -f "$PID_FILE"
        echo "Script stopped (PID $PID)."
    else
        rm -f "$PID_FILE"
        echo "Process not found, removed stale PID file."
    fi
}

# Function to check the status of the script
status_script() {
    if [ -f "$PID_FILE" ] && ps -p "$(cat "$PID_FILE")" > /dev/null 2>&1; then
        echo "Script is running (PID $(cat "$PID_FILE"))."
    else
        echo "Script is not running."
    fi
}

# Main entry point
case "$1" in
    START)
        start_script
        ;;
    STOP)
        stop_script
        ;;
    STATUS)
        status_script
        ;;
    run)
        run_monitor
        ;;
    *)
        echo "Usage: $SCRIPT_NAME {START|STOP|STATUS}"
        exit 1
        ;;
esac
