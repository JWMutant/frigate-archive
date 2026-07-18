# Developer Guide

This guide explains the architecture, development standards, release process, and design philosophy behind Frigate Archive.

Whether you're fixing a bug, adding a feature, or preparing a release, this guide provides the conventions used throughout the project.

> **Documentation Version:** v2.3.0  
> Applies to Frigate Archive v2.2.0 and later.

---

## In This Guide

- Project philosophy
- Repository structure
- Module architecture
- Coding standards
- Logging
- Error handling
- Testing
- Versioning
- Release process
- Documentation standards

---

## Project Philosophy

Frigate Archive is designed around four core principles:

- **Safety** – Never risk data loss.
- **Reliability** – Validate operations before making changes.
- **Maintainability** – Keep code modular and easy to understand.
- **Transparency** – Produce clear logs and meaningful error messages.

Every feature should support one or more of these principles.

---

# Repository Structure

```text
frigate-archive/
├── archive.sh
├── restore.sh
├── install.sh
├── uninstall.sh
├── healthcheck.sh
├── config.conf.example
├── VERSION
├── CHANGELOG.md
├── README.md
├── CONTRIBUTING.md
├── SECURITY.md
├── LICENSE
│
├── docs/
│   ├── getting-started.md
│   ├── installation.md
│   ├── configuration.md
│   ├── archive-engine.md
│   ├── restore-wizard.md
│   ├── healthcheck.md
│   ├── troubleshooting.md
│   ├── faq.md
│   └── developer-guide.md
│
├── modules/
│   ├── archive/
│   └── restore/
│
└── assets/
```

---

# Module Architecture

The project is organised into modular components.

## Archive Engine

Responsible for:

- Storage monitoring
- Recording transfer
- Verification
- Database cleanup
- Notifications
- Runtime management

---

## Restore Wizard

Responsible for:

- Archive browsing
- Restore preview
- Free-space validation
- File restoration
- Checksum verification

---

## Future Direction

Version 3.x will introduce a shared `modules/common/` framework to reduce duplicated functionality across the project.

Planned shared components include:

- Logging
- Configuration
- Runtime locks
- Helper functions
- Terminal formatting
- Notifications

---

# Coding Standards

## Shell

- Bash only
- POSIX-compatible where practical
- Four-space indentation
- Meaningful function names
- Consistent variable naming

---

## Functions

Functions should:

- Perform one task
- Return meaningful exit codes
- Log important actions
- Validate inputs where appropriate

---

## Variables

Configuration values belong in:

```text
config.conf
```

Avoid hard-coded paths or values within scripts.

---

# Logging

Every major operation should:

- Log the action being performed
- Report success or failure
- Include meaningful error messages
- Avoid unnecessary verbosity

Logs should help diagnose problems without requiring code inspection.

---

# Error Handling

When an unexpected condition occurs:

1. Detect the problem.
2. Display a clear error message.
3. Log the failure.
4. Exit safely without risking data loss.

Never continue after a failed verification step.

---

# Testing

Before submitting changes:

Run:

```bash
bash healthcheck.sh
```

Check shell syntax:

```bash
find . -name "*.sh" -exec bash -n {} \;
```

Verify:

- Archive operations
- Restore operations
- Installer
- Uninstaller
- Health Check

New features should be tested in both Test Mode and normal operation where applicable.

---

# Versioning

Frigate Archive follows Semantic Versioning.

- **Major** – Breaking changes or significant architectural changes.
- **Minor** – New features and enhancements.
- **Patch** – Bug fixes and maintenance updates.

Examples:

```text
2.2.0
2.3.0
3.0.0
```

---

# Release Process

Typical release workflow:

1. Complete development.
2. Update documentation.
3. Update `CHANGELOG.md`.
4. Update `VERSION`.
5. Run Health Check.
6. Validate shell syntax.
7. Commit changes.
8. Create a Git tag.
9. Publish the GitHub Release.

---

# Documentation Standards

All documentation follows a common structure:

- Purpose
- In This Guide
- Prerequisites
- Main Content
- Best Practices (where applicable)
- Related Guides

Documentation should explain **why**, not just **how**.

---

# Contributing

Please review:

- `CONTRIBUTING.md`
- `SECURITY.md`

before submitting pull requests or reporting security issues.

---

# Roadmap

Current priorities include:

- Complete the documentation library
- Improve visual documentation
- Add project screenshots
- Introduce shared common modules
- Expand automated testing

---

## Related Guides

- [Getting Started](getting-started.md)
- [Installation](installation.md)
- [Configuration](configuration.md)
- [Archive Engine](archive-engine.md)
- [Restore Wizard](restore-wizard.md)
- [Health Check](healthcheck.md)
- [Troubleshooting](troubleshooting.md)
- [FAQ](faq.md)
