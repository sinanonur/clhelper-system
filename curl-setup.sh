#!/bin/bash

# Create a temporary file to download the main setup script
TMPFILE=$(mktemp)

# URL of the main setup script
SETUP_URL="https://raw.githubusercontent.com/sinanonur/clhelper-system/refs/heads/main/setup.sh"

# Download the setup script into the temporary file
echo "Downloading the setup script..."
curl -fsSL "$SETUP_URL" -o "$TMPFILE"

# Check if the download was successful
if [ $? -ne 0 ]; then
    echo "Failed to download the setup script. Please check the URL and try again."
    rm -f "$TMPFILE"
    exit 1
fi

# Run the setup script
echo "Running the setup script..."
bash "$TMPFILE"

# Clean up the temporary file
rm -f "$TMPFILE"
