# ==============================================================================
# Granite Docling Demo Makefile
# ==============================================================================

.PHONY: help
.DEFAULT_GOAL := help

# ==============================================================================
# 📋 HELP & INFORMATION
# ==============================================================================

help: ## Show this help message
	@echo "==================================="
	@echo "Granite Docling Demo - Available Tasks"
	@echo "==================================="
	@echo ""
	@echo "👤 NEW DEVELOPER SETUP:"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## .*NEW DEVELOPER/ {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)
	@echo ""
	@echo "🧑‍💻 DAILY DEVELOPMENT:"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## .*DEVELOPMENT/ {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)
	@echo ""
	@echo "🚀 DEPLOYMENT & PRODUCTION:"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## .*DEPLOYMENT/ {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)
	@echo ""
	@echo "🧪 TESTING & QUALITY:"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## .*TESTING/ {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)
	@echo ""
	@echo "🧹 MAINTENANCE & CLEANUP:"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## .*MAINTENANCE/ {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)
	@echo ""
	@echo "📊 MONITORING & ANALYSIS:"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## .*MONITORING/ {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)
	@echo ""

# ==============================================================================
# 👤 NEW DEVELOPER SETUP
# ==============================================================================

setup-poetry: ## NEW DEVELOPER: Install Poetry package manager
	@echo "🔧 Installing Poetry..."
	@curl -sSL https://install.python-poetry.org | python3 -
	@echo "✅ Poetry installed! Add to PATH: export PATH=\"\$$HOME/.local/bin:\$$PATH\""

setup-poetry-plugins: ## NEW DEVELOPER: Install required Poetry plugins
	@echo "🔧 Installing Poetry plugins..."
	@poetry self add poetry-plugin-shell
	@poetry self add poetry-plugin-export
	@echo "✅ Poetry plugins installed!"

setup-environment: ## NEW DEVELOPER: Create and configure Python environment
	@echo "🔧 Setting up Python environment..."
	@poetry env use python
	@poetry install
	@echo "✅ Environment ready!"
	@echo "💡 To activate environment, run: poetry shell"

setup-precommit: ## NEW DEVELOPER: Install and configure pre-commit hooks
	@echo "🔧 Installing pre-commit hooks..."
	@poetry run pre-commit install
	@echo "✅ Pre-commit hooks installed!"

setup-full: setup-poetry setup-poetry-plugins setup-environment setup-precommit ## NEW DEVELOPER: Complete setup for new developers
	@echo "🎉 Full setup complete! You're ready to develop."
	@echo ""
	@echo "Next steps:"
	@echo "  1. Run 'poetry env use python' to activate environment"
	@echo "  2. Run 'make dev-server' to start development server"
	@echo "  3. Run 'make test-all' to verify everything works"
	@echo "  4. Check 'make help' for more commands"

# ==============================================================================
# 🧑‍💻 DAILY DEVELOPMENT
# ==============================================================================

dev-server: ## DEVELOPMENT: Start Gradio development server with auto-reload (no model loading)
	@echo "🚀 Starting Gradio development server..."
	@NO_LLM=1 poetry run gradio src/app.py

dev-server-full: ## DEVELOPMENT: Start Gradio server with full model loading
	@echo "🚀 Starting Gradio development server with model loading..."
	@poetry run gradio src/app.py

dev-shell: ## DEVELOPMENT: Activate Poetry shell for development
	@echo "🐚 Starting Poetry development shell..."
	@echo "💡 Run this command in your terminal: poetry shell"
	@poetry env use python

dev-install: ## DEVELOPMENT: Install dependencies for development
	@echo "📦 Installing development dependencies..."
	@poetry install

dev-update: ## DEVELOPMENT: Update dependencies to latest versions
	@echo "🔄 Updating dependencies..."
	@poetry update

dev-add-dep: ## DEVELOPMENT: Add a new dependency (usage: make dev-add-dep PACKAGE=package_name)
	@if [ -z "$(PACKAGE)" ]; then \
		echo "❌ Usage: make dev-add-dep PACKAGE=package_name"; \
		exit 1; \
	fi
	@echo "➕ Adding dependency: $(PACKAGE)"
	@poetry add $(PACKAGE)

dev-add-dev-dep: ## DEVELOPMENT: Add a new dev dependency (usage: make dev-add-dev-dep PACKAGE=package_name)
	@if [ -z "$(PACKAGE)" ]; then \
		echo "❌ Usage: make dev-add-dev-dep PACKAGE=package_name"; \
		exit 1; \
	fi
	@echo "➕ Adding dev dependency: $(PACKAGE)"
	@poetry add --group dev $(PACKAGE)

# ==============================================================================
# 🚀 DEPLOYMENT & PRODUCTION
# ==============================================================================

build-requirements: ## DEPLOYMENT: Export requirements.txt for deployment
	@echo "📋 Exporting requirements.txt..."
	@poetry export --format requirements.txt --output requirements.txt --without-hashes
	@echo "✅ requirements.txt updated!"

validate-deployment: ## DEPLOYMENT: Validate deployment readiness
	@echo "🔍 Validating deployment readiness..."
	@echo "Checking Python version..."
	@python --version | grep -q "3.10" || (echo "❌ Python 3.10 required" && exit 1)
	@echo "Checking main app file..."
	@test -f src/app.py || (echo "❌ src/app.py not found" && exit 1)
	@echo "Checking README configuration..."
	@grep -q "app_file: src/app.py" README.md || (echo "❌ README.md missing app_file config" && exit 1)
	@echo "Checking requirements.txt..."
	@test -f requirements.txt || (echo "❌ requirements.txt not found, run 'make build-requirements'" && exit 1)
	@echo "✅ Deployment validation passed!"

deploy-prep: lint test-all build-requirements validate-deployment ## DEPLOYMENT: Prepare for deployment (lint, test, build)
	@echo "🚀 Deployment preparation complete!"
	@echo ""
	@echo "Ready for deployment to Hugging Face Spaces!"
	@echo "Next steps:"
	@echo "  1. Commit your changes"
	@echo "  2. Push to main branch for QA deployment"
	@echo "  3. Create PR to stable branch for production"

# ==============================================================================
# 🧪 TESTING & QUALITY
# ==============================================================================

lint: ## TESTING: Run code linting with Ruff
	@echo "🔍 Running Ruff linter..."
	@poetry run ruff check src/

lint-fix: ## TESTING: Run Ruff linter with auto-fix
	@echo "🔧 Running Ruff linter with auto-fix..."
	@poetry run ruff check --fix src/

format: ## TESTING: Format code with Ruff
	@echo "✨ Formatting code with Ruff..."
	@poetry run ruff format src/

format-check: ## TESTING: Check code formatting
	@echo "🔍 Checking code formatting..."
	@poetry run ruff format --check src/

test-syntax: ## TESTING: Check Python syntax
	@echo "🔍 Checking Python syntax..."
	@python -m py_compile src/app.py
	@find src/ -name "*.py" -exec python -m py_compile {} \;
	@echo "✅ Syntax check passed!"

test-imports: ## TESTING: Test that all imports work
	@echo "🔍 Testing imports..."
	@poetry run python -c "import src.app; print('✅ All imports successful!')"

test-precommit: ## TESTING: Run pre-commit hooks on all files
	@echo "🔍 Running pre-commit hooks..."
	@poetry run pre-commit run --all-files

test-app-loads: ## TESTING: Test that the Gradio app loads without errors
	@echo "🔍 Testing Gradio app loading..."
	@timeout 30s poetry run python -c "import src.app; print('✅ Gradio app loads successfully!')" || \
		(echo "❌ App failed to load within 30 seconds" && exit 1)

test-all: lint format-check test-syntax test-imports test-app-loads ## TESTING: Run all tests and quality checks
	@echo "✅ All tests passed!"

# ==============================================================================
# 🧹 MAINTENANCE & CLEANUP
# ==============================================================================

clean-pyc: ## MAINTENANCE: Remove Python bytecode files
	@echo "🧹 Cleaning Python bytecode files..."
	@find . -type f -name "*.pyc" -delete
	@find . -type d -name "__pycache__" -delete
	@echo "✅ Python bytecode cleaned!"

clean-poetry: ## MAINTENANCE: Clean Poetry cache
	@echo "🧹 Cleaning Poetry cache..."
	@poetry cache clear pypi --all
	@echo "✅ Poetry cache cleaned!"

clean-all: clean-pyc clean-poetry ## MAINTENANCE: Clean all temporary and cache files
	@echo "✅ All cleanup complete!"

update-precommit: ## MAINTENANCE: Update pre-commit hooks
	@echo "🔄 Updating pre-commit hooks..."
	@poetry run pre-commit autoupdate
	@echo "✅ Pre-commit hooks updated!"

security-check: ## MAINTENANCE: Check for security vulnerabilities
	@echo "🔒 Checking for security vulnerabilities..."
	@poetry show --tree | grep -i security || echo "No obvious security issues found"
	@echo "💡 Consider running: poetry audit (requires poetry-audit-plugin)"

# ==============================================================================
# 📊 MONITORING & ANALYSIS
# ==============================================================================

info-env: ## MONITORING: Show environment information
	@echo "🔍 Environment Information:"
	@echo "Python Version: $$(python --version)"
	@echo "Poetry Version: $$(poetry --version)"
	@echo "Current Directory: $$(pwd)"
	@echo "Virtual Environment: $$(poetry env info --path 2>/dev/null || echo 'Not in Poetry venv')"

info-deps: ## MONITORING: Show dependency information
	@echo "📦 Dependency Information:"
	@poetry show --tree

info-outdated: ## MONITORING: Show outdated packages
	@echo "📊 Outdated Packages:"
	@poetry show --outdated

info-project: ## MONITORING: Show project configuration
	@echo "📋 Project Configuration:"
	@echo "Name: $$(poetry version | cut -d' ' -f1)"
	@echo "Version: $$(poetry version --short)"
	@echo ""
	@echo "🔍 Key Dependencies:"
	@poetry show gradio torch transformers spaces --no-dev 2>/dev/null || echo "Some dependencies not found"

stats-loc: ## MONITORING: Count lines of code
	@echo "📊 Lines of Code:"
	@echo "Python files:"
	@find src/ -name "*.py" | xargs wc -l | tail -1
	@echo "Configuration files:"
	@wc -l pyproject.toml README.md DEVELOPMENT.md 2>/dev/null || echo "Some files not found"

# ==============================================================================
# 🚢 DOCKER & CONTAINERIZATION (Future Use)
# ==============================================================================

docker-build: ## DEPLOYMENT: Build Docker image (for local testing)
	@echo "🐳 Building Docker image..."
	@echo "⚠️  Note: This is for local testing. Hugging Face Spaces builds automatically."
	@docker build -t granite-docling-demo .

docker-run: ## DEPLOYMENT: Run Docker container locally
	@echo "🚀 Running Docker container..."
	@docker run -p 7860:7860 granite-docling-demo

# ==============================================================================
# 🎯 SHORTCUTS & ALIASES
# ==============================================================================

install: dev-install ## ALIAS: Shortcut for dev-install
run: dev-server ## ALIAS: Shortcut for dev-server
check: test-all ## ALIAS: Shortcut for test-all
deploy: deploy-prep ## ALIAS: Shortcut for deploy-prep
clean: clean-all ## ALIAS: Shortcut for clean-all

# ==============================================================================
# 📝 CONFIGURATION
# ==============================================================================

check-python:
	@python -c "import sys; assert sys.version_info >= (3, 10), 'Python 3.10+ required'"
