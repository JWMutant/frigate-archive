# Contributing to Frigate Archive

First of all, thank you for taking the time to contribute to Frigate Archive.

Whether you're reporting a bug, suggesting a feature, improving the documentation, or submitting code, your contribution is appreciated.

---

# Project Goals

Frigate Archive exists to provide a safe, reliable, and easy-to-use archiving solution for Frigate running on Unraid.

The project's priorities are:

- Reliability before new features
- Safe handling of recordings
- Protection against accidental data loss
- Clear documentation
- Predictable behaviour
- Easy installation and maintenance

Whenever there is a choice between adding complexity or keeping the project reliable, reliability takes priority.

---

# Ways to Contribute

There are many ways to help improve Frigate Archive.

## Report Bugs

If you discover a bug, please use the **Bug Report** issue template.

Include as much information as possible, including:

- Frigate Archive version
- Unraid version
- Frigate version
- Health Check output
- Relevant logs
- Steps to reproduce the problem

---

## Suggest Features

Have an idea that would improve Frigate Archive?

Please use the **Feature Request** template.

Describe:

- The problem you're trying to solve
- Your proposed solution
- Alternative approaches you've considered

---

## Improve Documentation

Documentation improvements are always welcome.

Examples include:

- Installation guides
- Troubleshooting tips
- README improvements
- Wiki content
- Examples
- Typographical corrections

---

## Submit Code

Pull requests are welcome.

Please keep changes:

- Focused
- Well documented
- Thoroughly tested

Small pull requests are much easier to review than large ones.

---

# Development Guidelines

Please follow these guidelines when contributing code.

## Shell Scripts

- Use Bash.
- Write readable code.
- Prefer small functions.
- Comment complex logic.
- Avoid unnecessary dependencies.
- Preserve compatibility with current supported versions of Unraid.

---

## Backward Compatibility

Avoid breaking existing installations whenever possible.

If a change requires manual intervention, document it clearly in:

- README
- CHANGELOG

---

## Safety

Frigate Archive is designed to protect recordings.

Any code that:

- deletes files
- moves files
- modifies the database

must be carefully tested.

Safety always takes priority over speed.

---

# Testing

Before submitting a Pull Request, verify that the project still passes all checks.

## Installer

```bash
bash install.sh
```

## Health Check

```bash
bash healthcheck.sh
```

## Archive

Run a TEST_MODE archive.

```bash
bash archive.sh
```

## GitHub Actions

Ensure all GitHub Actions checks pass before requesting review.

---

# Commit Messages

Please write clear commit messages.

Good examples:

```
Add restore verification
Improve Health Check output
Fix archive verification bug
Update README installation guide
```

Avoid messages like:

```
Update
Fix
Changes
Stuff
```

---

# Pull Requests

Before opening a Pull Request:

- Ensure all tests pass.
- Keep the scope limited to one topic.
- Update documentation if needed.
- Update the CHANGELOG where appropriate.

---

# Coding Philosophy

Frigate Archive follows a simple philosophy.

**Reliable software is more valuable than feature-rich software.**

Features should:

- be easy to understand
- be easy to maintain
- improve reliability
- avoid unnecessary complexity

Every new feature should justify its existence.

---

# Community

Please be respectful when interacting with other users and contributors.

Constructive feedback and respectful discussion help improve the project for everyone.

---

# Thank You

Thank you for helping make Frigate Archive better.

Every contribution—whether it's a bug report, documentation improvement, feature suggestion, or code contribution—is appreciated.
