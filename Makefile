.PHONY: doctor

doctor:
	@echo "Checking prerequisites..."

	@command -v docker >/dev/null 2>&1 || (echo "❌ docker not installed"; exit 1)
	@command -v uv >/dev/null 2>&1 || (echo "❌ uv not installed"; exit 1)
	@command -v python3 >/dev/null 2>&1 || (echo "❌ python3 not installed"; exit 1)
	@command -v node >/dev/null 2>&1 || (echo "❌ node not installed"; exit 1)
	@command -v pnpm >/dev/null 2>&1 || (echo "❌ pnpm not installed"; exit 1)
	

	@echo "✅ tools present"

	@echo "Node version:"
	@node -v

	@echo "pnpm version:"
	@pnpm -v

	@echo "uv version:"
	@uv --version

	@echo "Python version:"
	@python3 --version

	@echo "Docker version:"
	@docker --version

	@echo "✅ environment looks good"