# Contributing to Kalki OS

Thank you for your interest in contributing to Kalki OS! We welcome all contributions, whether they're bug reports, feature requests, documentation improvements, or code contributions.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Workflow](#development-workflow)
- [Code Style](#code-style)
- [Submitting Changes](#submitting-changes)
- [Reporting Issues](#reporting-issues)
- [Documentation](#documentation)
- [Testing](#testing)
- [Code Review Process](#code-review-process)

## Code of Conduct

This project adheres to the [Contributor Covenant](https://www.contributor-covenant.org/version/2/1/code_of_conduct/). By participating, you are expected to uphold this code.

## Getting Started

1. **Fork the repository** on GitHub
2. **Clone your fork** locally:
   ```bash
   git clone https://github.com/your-username/kalki-os.git
   cd kalki-os
   ```
3. **Set up the development environment** (see [Development Setup](#development-setup))
4. **Create a feature branch** for your changes:
   ```bash
   git checkout -b feature/your-feature-name
   ```

## Development Setup

### Prerequisites

- A Linux-based operating system (Arch Linux recommended)
- Git
- Docker (for containerized builds)
- Python 3.9+
- make

### Setup Steps

1. Install build dependencies:
   ```bash
   sudo pacman -Syu --needed archiso mkinitcpio-archiso git
   ```

2. Clone the repository (if you haven't already):
   ```bash
   git clone https://github.com/kalki-os/kalki-os.git
   cd kalki-os
   ```

3. Set up pre-commit hooks:
   ```bash
   pre-commit install
   ```

## Development Workflow

1. **Create an issue** describing the bug or feature
2. **Assign the issue** to yourself if you're working on it
3. **Create a feature branch** from `main`
4. **Make your changes** following the code style guidelines
5. **Write tests** for your changes
6. **Run tests** locally
7. **Update documentation** if needed
8. **Commit your changes** with a descriptive message
9. **Push to your fork** and open a pull request

## Code Style

### Shell Scripts
- Use `shellcheck` for static analysis
- Follow the [Google Shell Style Guide](https://google.github.io/styleguide/shellguide.html)
- Use 4 spaces for indentation
- Quote all variable expansions
- Use `[[ ... ]]` for tests in bash

### Python
- Follow [PEP 8](https://www.python.org/dev/peps/pep-0008/)
- Use type hints for all functions and methods
- Use `black` for code formatting
- Use `isort` for import sorting
- Document all public functions with docstrings

## Submitting Changes

1. **Update the changelog** if your changes are user-visible
2. **Squash your commits** into logical units of work
3. **Write a good commit message**:
   ```
   type(scope): short description
   
   More detailed description if needed
   
   Fixes #123
   ```
   
   Common types:
   - feat: New feature
   - fix: Bug fix
   - docs: Documentation changes
   - style: Code style changes
   - refactor: Code changes that neither fix bugs nor add features
   - perf: Performance improvements
   - test: Adding or modifying tests
   - chore: Maintenance tasks

## Reporting Issues

When reporting issues, please include:

1. The version of Kalki OS you're using
2. Steps to reproduce the issue
3. Expected behavior
4. Actual behavior
5. Any error messages or logs

## Documentation

Good documentation is crucial for any open-source project. When making changes:

1. Update relevant documentation in the `docs/` directory
2. Add docstrings to all new functions and classes
3. Update the README if your changes affect setup or usage

## Testing

All code changes should include appropriate tests. To run the test suite:

```bash
make test
```

## Code Review Process

1. A maintainer will review your pull request
2. You may be asked to make changes
3. Once approved, a maintainer will merge your changes

## License

By contributing to Kalki OS, you agree that your contributions will be licensed under the project's [GPL-3.0 License](LICENSE).

## Questions?

If you have any questions, feel free to open an issue or join our [community chat](https://chat.kalki.os).
