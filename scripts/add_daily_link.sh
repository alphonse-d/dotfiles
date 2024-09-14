#!/bin/bash

# Define ZETTELKASTEN
source /home/alphonse/bin/config.env

# Define the path to daily note
# If this is executed before 3 am, append edited notes to the previous day's Daily note because it's actually an extension of the previous day's activity
JRN_DIR="$ZETTELKASTEN/Journal"
current_hour=$(date +"%H")
if [ "$current_hour" -lt 3 ]; then
  DAILY_NOTE="$JRN_DIR/$(date -d "yesterday" +"%Y%m%d").md"
else
  DAILY_NOTE="$JRN_DIR/$(date +"%Y%m%d").md"
fi

TIMESTAMP=$JRN_DIR/.timestamp
# Define path to store last run timestamp
# Get the current timestamp - Current time in seconds since the Unix epoch
CURRENT_TIMESTAMP=$(date +%s)

# Define function for missed day

missed_day() {
  touch "$DAILY_NOTE"
  cat <<EOF >"$DAILY_NOTE"
# $(date +"%F %A")

Yesterday:  [[$(date -d "yesterday" +"%Y%m%d")]]
Tomorrow:   [[$(date -d "tomorrow" +"%Y%m%d")]]

Missed Journal Entry.
EOF

}

if [ ! -f "$DAILY_NOTE" ]; then
  missed_day
fi

# Check if timestamp file exists; if not, create it with the current timestamp - 1 day
if [ ! -f "$TIMESTAMP" ]; then
  echo $(($CURRENT_TIMESTAMP - 86401)) >"$TIMESTAMP"
fi

# Read the last run timestamp
LAST_RUN=$(cat "$TIMESTAMP")

# Description: finds all files in ZETTELKASTEN excluding the JRN_DIR that are .md files with a timestamp after the one in file.
# Pipe to awk which strips the .md extension and adds "[[" and "]]" to create an obsidian link
FILES_TO_LINK=$(find $ZETTELKASTEN -type d -path $JRN_DIR -prune -o -type f -name "*.md" -newermt @$LAST_RUN -print | awk -F/ '{sub(/\.md$/, "", $NF); print "[["$NF"]]"}')

if [ -n "$FILES_TO_LINK" ]; then
  echo -e "\nNotes touched since last run on $(date -d @$LAST_RUN):" >>"$DAILY_NOTE"
  echo "$FILES_TO_LINK" >>"$DAILY_NOTE"
fi

# Update the last run timestamp
echo "$CURRENT_TIMESTAMP" >"$TIMESTAMP"
