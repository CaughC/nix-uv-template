.PHONY: init

init:
	@echo "Reloading Nix environment with direnv..."
	direnv reload
	@echo "Synchronizing Python packages with uv..."
	uv sync
	@echo "Environment reloaded and packages synchronized."
