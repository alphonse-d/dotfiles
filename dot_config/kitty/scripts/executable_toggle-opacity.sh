#!/usr/bin/env bash

# Get current opacity
current=$(kitty @ get-config background_opacity | awk '{print $2}')

# Fallback if not set
if [[ -z "$current" ]]; then
  current="1.0"
fi

# Toggle
if [[ "$current" == "1.0" ]]; then
  kitty @ set-background-opacity 0.9
else
  kitty @ set-background-opacity 1.0
fi

