#!/usr/bin/env bash

# Check if the correct number of arguments is provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <log_file> <keyword>"
    exit 1
fi

LOG_FILE=$1
KEYWORD=$2
OUTPUT_ERRORS="errors_found.txt"
OUTPUT_COUNT="errors_count.txt"

# Notify user which log file and keyword are being used
echo "Searching for keyword '$KEYWORD' in file '$LOG_FILE'..."

# Extract lines containing the keyword and save to errors file
grep "$KEYWORD" "$LOG_FILE" > "$OUTPUT_ERRORS"

# Count the number of lines found
ERROR_COUNT=$(wc -l < "$OUTPUT_ERRORS")

# Save the count to a separate file
echo "$ERROR_COUNT" > "$OUTPUT_COUNT"

# Print the results
echo "Number of errors found: $ERROR_COUNT (saved in '$OUTPUT_COUNT')"
echo "All errors have been saved to '$OUTPUT_ERRORS'"
