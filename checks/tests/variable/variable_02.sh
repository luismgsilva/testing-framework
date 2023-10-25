#!/bin/bash

# This functional test verifies that the input variable remains defined
# upon initialization with a input variable configuration file.

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

# Create the input variable configuration file
cat <<'EOF' > config/vars.json
{ "VARIABLE": "value" }
EOF

# Initialize and execute BSF
bsf -C ws/ init $(pwd)/config/ 	> /dev/null

# Get the actual output from BSF vars commmand
output=$(bsf -C ws/ vars)

# Check if the actual output matches the expected output
if [ "$output" = "$expected_output" ]; then
    echo "Passed: $(basename "$0")"
else
    echo "Failed: $(basename "$0")"
fi
