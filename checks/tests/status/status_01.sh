#!/bin/bash

# This functional test verifies the task' status.

# Define the expected output
expected_output="Passed: test01
Failed: test02"

# Create the required directories
mkdir config/ ws/

# Create the configuration file
cat <<EOF > config/config.json
{
	"tasks": {
		"test01": { "execute": "true" },
		"test02": { "execute": "false" }
	}
}
EOF

# Initialize and execute BSF
bsf -C ws/ init $(pwd)/config/	> /dev/null
bsf -C ws/ execute		> /dev/null

# Get the actual output from BSF status commmand
output=$(bsf -C ws/ status)

# Check if the actual output matches the expected output
if [ "$output" = "$expected_output" ]; then
    echo "Passed: $(basename "$0")"
else
    echo "Failed: $(basename "$0")"
fi



