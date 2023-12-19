#!/bin/bash

# This functional test verifies the locking system by running a
# sleep command within BSF and then executing BSF once more.

# Define the expected output
expected_output=$(cat <<EOF
bsf: Could not get lock
EOF
)

# Create the required directories
mkdir config/ ws/

# Create the configuration file
cat <<EOF > config/config.json
{
	"tasks": { "test01": { "execute": "sleep 5" } }
}
EOF

# Initialize and execute BSF
bsf -C ws/ init $(pwd)/config/ > /dev/null
(bsf -C ws/ execute &> /dev/null) &
sleep 1

# Get the actual output from BSF execute commmand
output=$(bsf -C ws/ execute)

# Check if the actual output matches the expected output
if [ "$output" = "$expected_output" ]; then
    echo "Passed: $(basename "$0")"
else
    echo "Failed: $(basename "$0")"
fi