# Makefile for running common project tasks

# The default target to run when no arguments are given
.PHONY: all
all: help

# Run the test script
.PHONY: test
test:
	./test

# Update snapshot by running the update_snapshot.zsh script
.PHONY: update-snapshot
update-snapshot:
	./tests/update_snapshot.zsh

# Update the README by running the update_readme_help.zsh script
.PHONY: update-readme
update-readme:
	./tools/update_readme_help.zsh $(ARGS)

# Install the pre-commit hook
.PHONY: install-pre-commit
install-pre-commit:
	@echo "Installing pre-commit hook..."
	@echo "#!/usr/bin/env zsh\nmake test" > .git/hooks/pre-commit
	@chmod +x .git/hooks/pre-commit
	@echo "Pre-commit hook installed"

# Clean
.PHONY: clean
clean:
	rm -f .git/hooks/pre-commit

# Display help
.PHONY: help
help:
	@echo "Usage:"
	@echo "  make test                  Run the test script"
	@echo "  make update-snapshot       Run the update_snapshot.zsh script"
	@echo "  make update-readme         Run the update_readme_help.zsh script,"
	@echo "                             Use \`ARGS=-u make update-readme\` to"
	@echo "                             also update snapshot."
	@echo "  make install-pre-commit    Install the pre-commit hook"
	@echo "  make clean                 Clean"

