<div align="center">

<img src="assets/branding/logo.png" alt="Frigate Archive Logo" width="180">

<br>

<img src="assets/banner.png" alt="Frigate Archive Banner">

# 📦 Frigate Archive

### Complete Archive & Restore Toolkit for Frigate running on Unraid

Automatically archive completed Frigate recordings to long-term storage and safely restore them when required.

![Platform](https://img.shields.io/badge/Platform-Unraid-red)
![Frigate](https://img.shields.io/badge/Frigate-0.17+-blue)
![License](https://img.shields.io/badge/License-MIT-green)
![Shell](https://img.shields.io/badge/Bash-5.x-yellow)
![Status](https://img.shields.io/badge/Status-Production_Ready-brightgreen)

</div>

---

# Overview

Frigate Archive is a production-ready toolkit built specifically for **Frigate running on Unraid**.

It provides a complete workflow for managing recordings:
The project is designed to be modular, production-ready, and easy to maintain, with dedicated tools for installation, archiving, restoration, validation, and ongoing maintenance.

-   📦 Archive Engine
-   🔄 Restore Wizard
-   🩺 Health Check
-   ⚙️ Guided Installer
-   🧹 Runtime Cleanup Utility
-   🔒 Safe database-aware archiving

Unlike simple file-copy scripts, Frigate Archive verifies transfers before removing source recordings and safely cleans the Frigate database after successful archiving.

---

# Why Frigate Archive?

Fast SSD or cache storage is ideal for active Frigate recordings, while protected array storage provides a more suitable location for long-term retention.

Frigate Archive automates this workflow with verification, logging, and safety checks built in.

---

# Features

## 📦 Archive Engine

-   Threshold-based automatic archiving
-   Safe rsync transfers
-   Archive verification
-   Database cleanup
-   Automatic database backups
-   Detailed logging
-   Lock protection
-   Test mode

## 🔄 Restore Wizard

-   Interactive archive browser
-   Restore preview
-   Storage validation
-   Safe merge
-   Checksum verification
-   Archive preservation
-   Restore logging

> **Current limitation:** The Restore Wizard restores recording files
> only. It does not recreate deleted Frigate database metadata.

## 🩺 Health Check

-   Configuration validation
-   Shell syntax validation
-   Runtime validation
-   Git repository checks
-   Restore subsystem validation

## ⚙️ Installer & Cleanup

-   Guided installation
-   Runtime cleanup utility
-   Version management
-   GitHub Actions validation

---

# Workflow

```text
Recording Drive
      │
      ▼
 Archive Engine
      │
      ▼
Verification
      │
      ▼
Database Cleanup
      │
      ▼
Long-term Archive
```

```text
Long-term Archive
      │
      ▼
 Restore Wizard
      │
      ▼
Restore Preview
      │
      ▼
Verification
      │
      ▼
Recording Drive
```

---

# Quick Start

```bash
git clone https://github.com/JWMutant/frigate-archive.git
cd frigate-archive
bash install.sh
```

Run a health check:

```bash
bash healthcheck.sh
```

Test the Archive Engine:

```bash
bash archive.sh
```

Browse archived recordings:

```bash
bash restore.sh
```

---

# 📚 Documentation

Whether you're installing Frigate Archive for the first time or looking for advanced configuration, the documentation library has you covered.

| Guide | Description |
|-------|-------------|
| [Getting Started](docs/getting-started.md) | Install, configure, and test Frigate Archive in minutes. |
| [Installation](docs/installation.md) | Detailed installation and upgrade instructions. |
| [Configuration](docs/configuration.md) | Configure paths, thresholds, notifications, and runtime options. |
| [Archive Engine](docs/archive-engine.md) | Learn how automatic archiving works and how to schedule it. |
| [Restore Wizard](docs/restore-wizard.md) | Restore archived recordings safely with verification. |
| [Health Check](docs/healthcheck.md) | Validate your installation and diagnose problems. |
| [Troubleshooting](docs/troubleshooting.md) | Resolve common issues and common error messages. |
| [FAQ](docs/faq.md) | Frequently asked questions and best practices. |
| [Developer Guide](docs/developer-guide.md) | Contributing, project structure, and development workflow. |

---

# Configuration

Edit `config.conf` and configure:

| Setting | Purpose |
|---------|---------|
| SOURCE | Recording location |
| ARCHIVE | Archive destination |
| CONTAINER | Frigate container name |
| FRIGATE_DB | SQLite database path |
| START_THRESHOLD | Start archive percentage |
| STOP_THRESHOLD | Stop archive percentage |

Leave `TEST_MODE=true` during initial testing.

---

# Project Structure

```text
frigate-archive/
├── archive.sh
├── restore.sh
├── install.sh
├── uninstall.sh
├── healthcheck.sh
├── VERSION
├── CHANGELOG.md
├── README.md
├── CONTRIBUTING.md
├── SECURITY.md
├── LICENSE
├── config.conf.example
├── modules/
│   ├── archive/
│   │   ├── archive.sh
│   │   ├── checks.sh
│   │   ├── database_cleanup.sh
│   │   ├── logging.sh
│   │   ├── notifications.sh
│   │   ├── notify.sh
│   │   ├── transfer.sh
│   │   ├── utils.sh
│   │   └── verify.sh
│   └── restore/
│       ├── core/
│       │   ├── checks.sh
│       │   ├── context.sh
│       │   └── logging.sh
│       ├── menu.sh
│       ├── transfer.sh
│       └── verify.sh
└── assets/
    ├── branding/
    └── screenshots/
```

---

# Roadmap

## Completed

- Archive Engine
- Restore Wizard
- Installer
- Uninstaller
- Health Check
- GitHub Actions
- Branding
- Issue Templates
- Contributing Guide
- Security Policy

## Planned

- Complete documentation library
- Project screenshots
- Mermaid workflow diagrams
- Dynamic GitHub badges
- Shared common module framework
- Enhanced restore metadata support
- Optional notification providers

---

# Contributing

Contributions are welcome. Please read `CONTRIBUTING.md` before
submitting pull requests.

# Security

Please see `SECURITY.md` for reporting security issues.

# License

Released under the MIT License.

---

<div align="center">

## ⭐ If Frigate Archive has been useful, please consider starring the repository!

Thank you for supporting the project!

</div>
