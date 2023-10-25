#!/bin/bash

# This functional test verifies that the options to be supplied to the
# compare script via the compare command are correctly configured

# Define the expected output
expected_output=$(cat <<EOF
-f test -h $(pwd)/ws/workspace/compare/HEAD^/persistent_ws/test01/:HEAD^  -h $(pwd)/ws/workspace/compare/HEAD/persistent_ws/test01/:HEAD
EOF
)

# Create the required directories
mkdir config/ ws/

# Create the configuration file
cat <<'EOF' > config/config.json
{
	"tasks": {
		"test01": {
			"execute": "date > $var(@PERSISTENT_WS)/test",
			"comparator": "echo '$var(@OPTIONS)'"
		 }
	}
}
EOF

# Initialize and execute BSF
bsf -C ws/ init $(pwd)/config/ 	> /dev/null
bsf -C ws/ git init		&> /dev/null
bsf -C ws/ execute 		> /dev/null
bsf -C ws/ publish 		> /dev/null
sleep 1
bsf -C ws/ execute		> /dev/null
bsf -C ws/ publish 		> /dev/null

# Get the actual output from BSF compare commmand
output=$(bsf -C ws/ compare test01 HEAD^:HEAD -f test)

# Check if the actual output matches the expected output
if [ "$output" = "$expected_output" ]; then
    echo "Passed: $(basename "$0")"
else
    echo "Failed: $(basename "$0")"
fi


