.PHONY: test slow validate lint fmt refs
test:
	pytest -m "not slow"
slow:
	pytest -m slow
validate:
	pytest tests/validation
lint:
	ruff check src tests scripts && ruff format --check src tests scripts
fmt:
	ruff format src tests scripts && ruff check --fix src tests scripts
refs:
	octave-cli --no-gui --eval "addpath('refs/matpower'); export_all"
