# Frigate Archive

> A safe, automated archiving solution for Frigate that moves recordings to long-term storage, verifies every transfer, and keeps Frigate's database synchronized.

---

## Overview

Frigate Archive is a modular archive management system designed specifically for **Frigate NVR** running on **Unraid**.

Unlike simple backup scripts that only copy recordings, Frigate Archive was built with one primary goal:

**Never sacrifice data integrity for automation.**

Every archive operation is verified before recordings are removed, and Frigate's database is automatically synchronized so archived recordings never leave stale database entries behind.

The result is an archive system that can safely run unattended while protecting both your recordings and your Frigate installation.

---

# Features

✔ Intelligent archive scheduling based on disk usage

✔ Archives only completed recording days

✔ High-performance `rsync` transfers

✔ Automatic transfer verification

✔ Automatic source cleanup after successful verification

✔ Frigate database synchronization

✔ Automatic database backup creation

✔ Automatic database backup retention

✔ SQLite VACUUM optimization

✔ Lock file protection

✔ Comprehensive logging

✔ Configurable archive thresholds

✔ Test mode for safe validation

✔ Modular architecture

---

# Why Frigate Archive?

Frigate can generate hundreds of gigabytes of recordings very quickly.

Many users want to:

- Keep recent recordings on fast local storage.
- Move older recordings to large-capacity storage.
- Avoid filling SSDs.
- Preserve Frigate's database integrity.

Frigate Archive automates this process while ensuring recordings are never deleted until they have been successfully verified in the archive.

---

# How It Works

```
Recording Drive
        │
        ▼
Check Drive Usage
        │
        ▼
Find Oldest Complete Recording Day
        │
        ▼
Verify Existing Archive (if present)
        │
        ▼
Transfer using rsync
        │
        ▼
Verify Transfer
        │
        ▼
Delete Source Recordings
        │
        ▼
Synchronize Frigate Database
        │
        ▼
Create Database Backup
        │
        ▼
Prune Old Database Backups
        │
        ▼
Complete
```

---

# Requirements

- Unraid 7.x or later
- Frigate Docker container
- rsync
- Docker
- Python 3 (via container)

---

# Project Structure

```
frigate-archive/
│
├── archive.sh
├── config.conf
├── README.md
├── CHANGELOG.md
├── LICENSE
│
├── backups/
├── logs/
│
└── modules/
    ├── archive.sh
    ├── checks.sh
    ├── database_cleanup.sh
    ├── logging.sh
    ├── notifications.sh
    ├── notify.sh
    ├── transfer.sh
    ├── utils.sh
    └── verify.sh
```

---

# Current Features

Version **2.0.0**

- Automated archive management
- Safe rsync transfers
- Archive verification
- Database synchronization
- Database backup rotation
- Lock file protection
- Configurable thresholds
- Comprehensive logging

---

# Future Roadmap

## Version 2.1

- Improved notifications
- Enhanced reporting
- Additional archive statistics

## Version 2.2

- Installer
- Uninstaller
- Configuration validation

## Version 3.0

- Web interface
- Multiple archive destinations
- Compression support
- Archive indexing

---

# Contributing

Contributions, ideas, feature requests and bug reports are welcome.

Please open an Issue or submit a Pull Request.

---

# License

This project will be released under the MIT License.

---

# Acknowledgements

Developed for the Frigate and Unraid communities.

Special thanks to everyone who tests, reports bugs and contributes ideas that help improve the project.
