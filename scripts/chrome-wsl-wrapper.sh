#!/usr/bin/env bash

chrome_args=()

for arg in "$@"; do
  if [[ "$arg" == --user-data-dir=/tmp/* ]]; then
    profile_name="${arg##*/}"
    chrome_args+=("--user-data-dir=C:\\Users\\Green\\AppData\\Local\\Temp\\${profile_name}")
  else
    chrome_args+=("$arg")
  fi
done

exec "/mnt/c/Program Files/Google/Chrome/Application/chrome.exe" "${chrome_args[@]}" 2>&1
