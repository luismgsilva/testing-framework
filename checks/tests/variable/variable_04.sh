#!/bin/bash

# This functional test validates the functionality of input variable definition.

# Define the expected output
expected_output=$(cat <<EOF
Input Variable VARIABLE defined: value
EOF
)

# Create the required directories
mkdir config/ ws/

# Create the configuration file
cat <<'EOF' > config/config.json
{
	"sources": {},
	"tasks": {
		"test01": {
			"execute": "echo '$var(VARIABLE)'"
		 }
	}
}
EOF

# Initialize and execute BSF
bsf -C ws/ init $(pwd)/config/ 	> /dev/null
bsf -C ws/ set VARIABLE=value 	> /dev/null

# Get the actual output from BSF vars commmand
output=$(bsf -C ws/ vars)

# Check if the actual output matches the expected output
if [ "$output" = "$expected_output" ]; then
    echo "Passed: $(basename "$0")"
else
    echo "Failed: $(basename "$0")"
fi
