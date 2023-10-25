#!/bin/bash

# This functional test verifies that the task execution fails when
# an undefined input variable is present.

# Define the expected output
expected_output=$(cat <<EOF
bsf: Input variable not set - VARIABLE
EOF
)

# Create the required directories
mkdir config/ ws/

# Create the configuration file
cat <<'EOF' > config/config.json
{
	"tasks": {
		"test01": {
			"execute": "echo '$var(VARIABLE)'"
		 }
	}
}
EOF

# Initialize and execute BSF
bsf -C ws/ init $(pwd)/config/ 	> /dev/null

# Get the actual output from BSF execute commmand
output=$(bsf -C ws/ execute)

# Check if the actual output matches the expected output
if [ "$output" = "$expected_output" ]; then
    echo "Passed: $(basename "$0")"
else
    echo "Failed: $(basename "$0")"
fi