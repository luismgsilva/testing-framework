#!/bin/bash

# This functional test verifies the git commit message #2

# Define the expected output
expected_output=$(cat <<EOF
{   "test01": {     "tool1": "This is a version",     "tool2": "This is a version"   } }
EOF
)

# Create the required directories
mkdir config/ ws/

# Create the configuration file
cat <<'EOF' > config/config.json
{
	"tasks": {
		"test01": {
			"execute": [
				"ruby $var(@CONFIG_SOURCE_PATH)/versions.rb tool1 > version1.json",
				"ruby $var(@CONFIG_SOURCE_PATH)/versions.rb tool2 > version2.json"
			],
			"publish_header": [
				"cat $var(@WORKSPACE)/version1.json",
				"cat $var(@WORKSPACE)/version2.json"
			]
		 }
	}
}
EOF

# Create a Ruby script to generate the version
cat <<EOF > config/versions.rb
require 'json'
config = { ARGV[0] => "This is a version" }
puts JSON.pretty_generate(config)
EOF

# Initialize and execute BSF
bsf -C ws/ init $(pwd)/config/ 	> /dev/null
bsf -C ws/ execute 		> /dev/null
bsf -C ws/ git init 		&> /dev/null
bsf -C ws/ publish 		> /dev/null

# Get the actual output from BSF git commmand
output=$(bsf -C ws/ git show --pretty=format:%s -s HEAD)

# Check if the actual output matches the expected output
if [ "$output" = "$expected_output" ]; then
    echo "Passed: $(basename "$0")"
else
    echo "Failed: $(basename "$0")"
fi
