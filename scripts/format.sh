#!/bin/bash

# Check if SwiftFormat is installed
if ! command -v swiftformat &> /dev/null; then
    echo "SwiftFormat is not installed. Please install it using: brew install swiftformat"
    exit 1
fi

# Get the project root directory
PROJECT_DIR="$SRCROOT"

# Create a temporary file to track modified files
MODIFIED_FILES="/tmp/swiftformat_modified_files.txt"
touch "$MODIFIED_FILES"

# Run SwiftFormat and track modified files
swiftformat "$PROJECT_DIR" --config "$PROJECT_DIR/.swiftformat" --cache ignore --verbose | while read -r line; do
    if [[ $line == *"would have updated"* ]]; then
        file=$(echo "$line" | sed 's/.*would have updated \(.*\)/\1/')
        echo "$file" >> "$MODIFIED_FILES"
    fi
done

# Check if any files were modified
if [ -s "$MODIFIED_FILES" ]; then
    echo "The following files need formatting:"
    cat "$MODIFIED_FILES"
    rm "$MODIFIED_FILES"
    exit 1
else
    echo "All files are properly formatted."
    rm "$MODIFIED_FILES"
    exit 0
fi 