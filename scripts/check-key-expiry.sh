#!/bin/bash
set -euo pipefail

date=date
if [[ "$(uname -s)" == "Darwin" ]]; then
  # Use GNU date on Mac (must be separately installed using Homebrew)
  date=gdate
fi

# Get current date in seconds since epoch
current_date=$($date +%s)
# Date 30 days from now in seconds since epoch
expiry_threshold=$($date -d "+30 days" +%s)

# Check each key in the directory
exitcode=0
for key_file in superchain/gpg/*.asc; do
  # Get key expiry date (UNIX timestamp)
  expiry_date=$(gpg --with-colons --show-keys $key_file | grep pub: | cut -d: -f7)

  # If key has expiry date
  if [ ! -z "$expiry_date" ]; then
    echo "$key_file will expire on $($date -I -d "@$expiry_date")"
    if [ $expiry_date -lt $expiry_threshold ]; then
      echo "::error::GPG key $key_file will expire soon (on $($date -I -d "@$expiry_date"))"
      exitcode=1
    fi
  else
    echo "$key_file has no expiry date"
  fi
done

exit $exitcode