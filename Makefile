# Makefile for PyPropTest development tasks

.PHONY: help install test lint format type-check security clean quick-check pre-commit all-checks

# Default target
help:
	@echo "PyPropTest Development Commands"
	@echo "==============================="
	@echo ""
	@echo "Quick Commands:"
	@echo "  make quick-check    - Run quick pre-commit checks (fast)"
	@echo "  make pre-commit     - Run full pre-commit checks"
	@echo "  make all-checks     - Run all CI checks"
	@echo ""
	@echo "Individual Checks:"
	@echo "  make install        - Install dependencies"
	@echo "  make test           - Run all tests (unittest + pytest)"
	@echo "  make lint           - Run flake8 linting"
	@echo "  make format         - Format code with black and isort"
	@echo "  make type-check     - Run mypy type checking"
	@echo "  make security       - Run security analysis"
	@echo ""
	@echo "Utilities:"
	@echo "  make clean          - Clean up generated files"
	@echo "  make help           - Show this help message"

# Install dependencies
install:
	@echo "📦 Installing dependencies..."
	pip install -e ".[dev]"

# Run all tests
test:
	@echo "🧪 Running unittest tests..."
	python -m unittest discover tests -v
	@echo "🧪 Running pytest tests..."
	pytest --cov=pyproptest --cov-report=term-missing -v

# Run linting
lint:
	@echo "🔍 Running flake8 linting..."
	flake8 pyproptest --count --select=E9,F63,F7,F82 --show-source --statistics
	flake8 pyproptest --count --exit-zero --max-complexity=10 --max-line-length=88 --statistics

# Format code
format:
	@echo "🎨 Formatting code with black..."
	black pyproptest/ tests/
	@echo "📋 Sorting imports with isort..."
	isort pyproptest/ tests/

# Type checking
type-check:
	@echo "🔍 Running mypy type checking..."
	mypy pyproptest/

# Security analysis
security:
	@echo "🔒 Running security analysis..."
	bandit -r pyproptest/ -f json -o bandit-report.json
	safety check --json > safety-report.json || true

# Quick pre-commit check (fast)
quick-check:
	@echo "⚡ Running quick pre-commit checks..."
	./scripts/quick-check.sh

# Full pre-commit check
pre-commit:
	@echo "🚀 Running full pre-commit checks..."
	./scripts/pre-commit-checks.sh

# All CI checks
all-checks: install lint format type-check test security
	@echo "✅ All CI checks completed!"

# Clean up generated files
clean:
	@echo "🧹 Cleaning up generated files..."
	rm -f bandit-report.json
	rm -f safety-report.json
	rm -f coverage.xml
	rm -rf .coverage
	rm -rf .pytest_cache
	rm -rf .mypy_cache
	rm -rf __pycache__
	find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
	find . -type f -name "*.pyc" -delete 2>/dev/null || true
