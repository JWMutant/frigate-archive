# Changelog

All notable changes to this project will be documented in this file.

The format is based on Keep a Changelog and this project follows Semantic Versioning.

---

## [2.2.0] - 2026-07-17

### 🚀 Major Features

#### Restore Wizard

Introduced a fully interactive Restore Wizard for restoring archived Frigate recordings.

Features include:

- Interactive archive browser
- Date-based restore selection
- Archive statistics
- Restore preview before execution
- Recording-drive free-space validation
- Configurable restore safety margin
- Automatic destination creation
- Safe merge into existing recording folders
- Checksum verification after transfer
- Detailed restore logging
- Automatic restore lock management
- Graceful cancellation handling

---

### 🏗 Architecture

Added a dedicated modular Restore subsystem.

```
modules/
└── restore/
    ├── core/
    │   ├── checks.sh
    │   ├── context.sh
    │   └── logging.sh
    │
    ├── menu.sh
    ├── transfer.sh
    └── verify.sh
```

The Restore Wizard is now separated into logical components for easier maintenance and future expansion.

---

### ⚙ Installer

Improved installation process.

- Installer now validates Restore Wizard.
- Validates Restore module directory.
- Validates Restore core directory.
- Validates Restore controller.
- Validates all Restore modules.
- Recursive line-ending normalization.
- Recursive syntax validation.
- Improved installation summary.
- Updated post-install instructions.

---

### 🩺 Health Check

Expanded project validation.

Health Check now verifies:

- Restore controller
- Restore module directory
- Restore core directory
- Restore module syntax
- Restore script accessibility
- Restore runtime lock state

Project validation now covers the complete Archive and Restore subsystems.

---

### 🧹 Uninstaller

Improved runtime cleanup.

- Archive and Restore logs handled together.
- Archive and Restore lock files cleaned.
- Clearer configuration prompts.
- Improved uninstall summary.
- Better explanation of preserved data.

---

### 📖 Documentation

Documentation significantly expanded.

Added or updated:

- README
- CHANGELOG
- CONTRIBUTING.md
- SECURITY.md
- Restore documentation
- Restore workflow examples
- Branding assets

---

### 🧪 Validation

Project validation improvements include:

- GitHub Actions validation
- Recursive shell syntax checking
- Installer validation
- Restore validation
- Health Check validation

---

### 🔒 Safety

Restore operations now include:

- Free-space validation
- Read/write permission checks
- Archive integrity checks
- Destination validation
- Checksum verification
- Automatic lock handling
- Safe cancellation
- Archive preservation

---

### ⚠ Current Limitation

The Restore Wizard restores **recording files only**.

It does **not** recreate:

- Frigate database records
- Timeline entries
- Review entries
- Preview images
- Recording metadata

As a result, restored recordings may not immediately appear inside Frigate's Recordings or Review pages unless the database metadata also exists.

This limitation is expected and documented.

---

### ✅ Testing

Successfully validated using production data.

Verified:

- Archive browser
- Date selection
- Restore preview
- Restore execution
- Destination creation
- Destination merge
- File verification
- Archive preservation
- Lock cleanup
- Health Check
- Installer
- Uninstaller

---

## [2.1.1] - Previous Release

- Centralized version management
- Health Check improvements
- Installer improvements
- Uninstaller improvements
- Project validation improvements

---

## [2.1.0]

- Added project installer
- Added project uninstaller
- Added Health Check
- Improved archive validation
- Centralized configuration

---

## [2.0.0]

- Initial public release
- Automatic archive engine
- Database cleanup
- Logging
- Notifications
- Threshold-based archiving
