#!/bin/bash

# This functional test verifies the git commit message #3

# Define the expected output
expected_output=$(cat <<EOF
Hello, World!
EOF
)

# Create the required directories
mkdir config/ ws/

# Create the configuration file
cat <<'EOF' > config/config.json
{
	"tasks": {
		"test01": {
			"execute": "echo 'Hello, World!' > $var(@PERSISTENT_WS)/file"
		 }
	}
}
EOF

# Initialize and execute BSF
bsf -C ws/ init $(pwd)/config/ 	> /dev/null
bsf -C ws/ execute 		> /dev/null
bsf -C ws/ git init 		&> /dev/null
bsf -C ws/ publish 		> /dev/null

# Get the actual output from BSF ls commmand
output=$(bsf -C ws/ cat test01 file HEAD)

# Check if the actual output matches the expected output
if [ "$output" = "$expected_output" ]; then
    echo "Passed: $(basename "$0")"
else
    echo "Failed: $(basename "$0")"
fi
