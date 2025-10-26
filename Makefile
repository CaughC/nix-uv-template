# Usage: make init name=my_project
# This is unnecessary if you use nixuv (globbal template initializer)
init:
	@if [ -z "$(name)" ]; then \
		echo "❌ Please specify project name: make init name=my_project"; \
		exit 1; \
	fi
	@echo "🚀 Creating project '$(name)'..."
	@cp -r template $(name)
	@cd $(name) && direnv allow
	@echo "✅ Project '$(name)' created at ./$(name)"
