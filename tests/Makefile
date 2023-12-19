SHELL = /bin/bash


# Store the current directory
CURRENT_DIR := $(shell pwd)

# Prepare BSF
PREPARE := PATH="$(CURRENT_DIR)/../:$(PATH)"

# Find all shell scripts under the "tests" directory
SCRIPTS = $(shell find tests -type f -name "*.sh")

# Create a list of corresponding build directories outside of "tests"
BUILD_DIRS = $(patsubst tests/%.sh,build/%,$(SCRIPTS))

# Define the targets
.PHONY: check
check: $(BUILD_DIRS)

# Rule to create build directories and execute scripts
build/%: tests/%.sh
	@mkdir -p $@
	@cp $(CURRENT_DIR)/$< $@
	@cd $@ && $(PREPARE) $(CURRENT_DIR)/$@/$(notdir $@).sh

.PHONY: clean
clean:
	rm -rf build/
