#!/bin/bash

# This functional verifies the output redirection behavior during task execution.

# Define the expected output
expected_output=$(cat <<EOF
BSF Executing: echo This is a functional test
This is a functional test
EOF
)

# Create the required directories
mkdir config/ ws/

# Create the configuration file
cat <<EOF > config/config.json
{
	"tasks": {
		"test01": { "execute": "echo 'This is a functional test'" }
	}
}
EOF

# Initialize and execute BSF
bsf -C ws/ init $(pwd)/config/ 	> /dev/null
bsf -C ws/ execute 		> /dev/null

# Get the actual output from BSF log commmand
output=$(bsf -C ws/ log test01)

# Check if the actual output matches the expected output
if [ "$output" = "$expected_output" ]; then
    echo "Passed: $(basename "$0")"
else
    echo "Failed: $(basename "$0")"
fi
