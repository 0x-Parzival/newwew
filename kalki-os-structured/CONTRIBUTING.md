# Contributing to Kalki OS

Thank you for your interest in contributing to Kalki OS! This guide will help you get started with contributing to our modern, agentic Linux distribution project.

## 📋 Table of Contents

- [Project Structure](#project-structure)
- [Development Setup](#development-setup)
- [Contribution Guidelines](#contribution-guidelines)
- [Code Standards](#code-standards)
- [Testing Requirements](#testing-requirements)
- [Submission Process](#submission-process)

## 🏗️ Project Structure

Our project follows a structured approach with clear separation of concerns:

```
kalki-os/
├── src/                    # Source code by functionality
├── build/                  # Build system and scripts
├── docs/                   # Documentation
├── tests/                  # Testing framework
├── tools/                  # Development tools
└── workspace/              # Build workspace
```

### Key Directories

- **src/core/**: Core OS components (ISO profiles, base system)
- **src/apps/**: Dharmic applications
- **src/ai-system/**: AI integration components
- **src/avatar-system/**: Avatar personalities
- **build/scripts/**: All build scripts
- **tools/validation/**: Validation and testing tools

## 🛠️ Development Setup

### Prerequisites

1. **Arch Linux Environment** (native or Docker)
2. **Required packages**: Install using our setup script
   ```bash
   bash build/scripts/setup-build-env.sh
   ```

3. **Development tools**:
   ```bash
   sudo pacman -S git shellcheck python3 python-pip
   ```

### Initial Setup

```bash
# Clone the repository
git clone <repository-url> kalki-os
cd kalki-os

# Setup build environment
bash build/scripts/setup-build-env.sh

# Verify setup
bash build/scripts/check-dependencies.sh

# Run initial tests
bash tests/run-basic-tests.sh
```

## 📝 Contribution Guidelines

### Types of Contributions

1. **Bug Fixes**: Fix issues in existing functionality
2. **Feature Development**: Add new features or improve existing ones
3. **Documentation**: Improve documentation and guides
4. **Testing**: Add or improve test coverage
5. **Build System**: Improve build processes and tools

### Before You Start

1. **Check Issues**: Look for existing issues or create a new one
2. **Discuss Changes**: For major changes, discuss in issues first
3. **Fork Repository**: Create your own fork for development

### Development Workflow

1. **Create Feature Branch**:
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make Changes**: Follow our coding standards
3. **Test Changes**: Run relevant tests
4. **Commit Changes**: Use conventional commit messages
5. **Push and Create PR**: Submit for review

## 🔧 Code Standards

### Shell Scripts

- Use `#!/bin/bash` shebang
- Enable strict mode: `set -euo pipefail`
- Use shellcheck for linting:
  ```bash
  find . -name "*.sh" -exec shellcheck {} +
  ```

### Python Code

- Follow PEP 8 style guide
- Use type hints where applicable
- Include docstrings for functions
- Use virtual environments for dependencies

### Directory Structure Rules

- **Scripts**: Place build scripts in `build/scripts/`
- **Source Code**: Organize by functionality in `src/`
- **Tests**: Mirror source structure in `tests/`
- **Documentation**: Use appropriate `docs/` subdirectory

### Naming Conventions

- **Scripts**: Use kebab-case (e.g., `build-kalki.sh`)
- **Directories**: Use kebab-case (e.g., `ai-system`)
- **Variables**: Use UPPER_CASE for constants, lower_case for variables
- **Functions**: Use snake_case

## 🧪 Testing Requirements

### Before Submitting

1. **Run Basic Tests**:
   ```bash
   bash tests/run-basic-tests.sh
   ```

2. **Component-Specific Tests**:
   ```bash
   # For AI system changes
   bash tests/test-ai-integration.sh
   
   # For avatar system changes
   bash tests/test-avatar-system.sh
   
   # For build system changes
   bash tests/test-build-system.sh
   ```

3. **Full Build Test** (for major changes):
   ```bash
   bash build/scripts/build-minimal-iso.sh --test
   ```

4. **Validation Scripts**:
   ```bash
   bash tools/validation/validate-phase5.sh
   bash tools/validation/validate-phase6.sh
   ```

### Test Coverage Requirements

- **New Features**: Must include tests
- **Bug Fixes**: Must include regression tests
- **Build Scripts**: Must be tested in clean environment
- **Documentation**: Must be validated for accuracy

## 📤 Submission Process

### Pull Request Guidelines

1. **Clear Title**: Describe what the PR does
2. **Detailed Description**: Explain the changes and why
3. **Link Issues**: Reference related issues
4. **Test Results**: Include test output
5. **Screenshots**: For UI changes

### PR Checklist

- [ ] Code follows project standards
- [ ] Tests pass locally
- [ ] Documentation updated if needed
- [ ] Commit messages are clear
- [ ] No merge conflicts
- [ ] Changes are focused and atomic

### Review Process

1. **Automated Checks**: CI/CD runs tests
2. **Code Review**: Maintainers review code
3. **Testing**: Changes are tested in build environment
4. **Approval**: At least one maintainer approval required
5. **Merge**: Squash and merge preferred

## 🎯 Specific Contribution Areas

### Core System Development

- Focus on `src/core/` directory
- Test changes with minimal builds
- Ensure compatibility with all features

### Application Development

- Work in `src/apps/` directory
- Follow dharmic computing principles
- Integrate with avatar system

### AI System Enhancement

- Contribute to `src/ai-system/`
- Test with SEAL learning system
- Ensure Agent Zero compatibility

### Build System Improvements

- Enhance `build/scripts/`
- Improve GUI build tools
- Add validation checks

### Documentation

- Update relevant `docs/` sections
- Keep README files current
- Add examples and tutorials

## 🐛 Bug Reports

### Information to Include

1. **Environment**: OS, version, hardware
2. **Steps to Reproduce**: Clear, numbered steps
3. **Expected Behavior**: What should happen
4. **Actual Behavior**: What actually happens
5. **Logs**: Relevant error messages
6. **Configuration**: Any custom settings

### Bug Report Template

```markdown
**Environment:**
- OS: Arch Linux
- Kalki OS Version: 
- Hardware: 

**Bug Description:**
Brief description of the bug

**Steps to Reproduce:**
1. 
2. 
3. 

**Expected Behavior:**
What should happen

**Actual Behavior:**
What actually happens

**Logs:**
```
Relevant logs here
```

**Additional Context:**
Any other relevant information
```

## 💡 Feature Requests

### Before Requesting

1. Check existing issues and documentation
2. Consider if it fits Kalki OS philosophy  
3. Think about implementation complexity

### Feature Request Template

```markdown
**Feature Description:**
Clear description of the requested feature

**Use Case:**
Why is this feature needed?

**Proposed Implementation:**
How could this be implemented?

**Alternatives Considered:**
Other approaches considered

**Additional Context:**
Any other relevant information
```

## 🏷️ Issue Labels

- `bug`: Something isn't working
- `enhancement`: New feature or request
- `documentation`: Improvements or additions to docs
- `good first issue`: Good for newcomers
- `help wanted`: Extra attention needed
- `question`: Question about the project

## 📞 Getting Help

- **Issues**: For bugs and feature requests
- **Discussions**: For questions and general discussion
- **Documentation**: Check `docs/` directory first
- **Code Review**: Learn from existing PR reviews

## 🎉 Recognition

Contributors are recognized in:
- Release notes
- Contributors section in README
- Hall of fame in documentation

Thank you for contributing to Kalki OS!