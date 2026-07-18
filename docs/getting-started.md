# Getting Started

This guide walks you through installing, configuring, testing, and verifying Frigate Archive for the first time.

---

## In This Guide

- System requirements
- Installing Frigate Archive
- Running the installer
- Configuring the project
- Running the Health Check
- Testing the Archive Engine
- Testing the Restore Wizard
- Scheduling automatic archiving

---

## Prerequisites

Before starting, ensure you have:

- Unraid
- Frigate installed and running
- A recording location
- An archive location
- Terminal access

This guide provides a quick introduction to installing, configuring, and testing Frigate Archive on Unraid.

Frigate Archive includes:

- An automatic Archive Engine
- An interactive Restore Wizard
- A Health Check utility
- A guided installer
- A safe runtime cleanup utility

---

## Requirements

Before installing Frigate Archive, confirm that your system has:

- Unraid
- Frigate running in Docker
- Bash
- Docker
- rsync
- A recording storage location
- A separate archive destination
- Access to the Frigate SQLite database

Frigate Archive is designed specifically for Unraid systems.

---

## Download the Project

Open an Unraid terminal and choose where you want to store the project.

The recommended location is:

```text
/boot/config/custom/frigate-archive
```

Clone the repository:

```bash
cd /boot/config/custom

git clone https://github.com/JWMutant/frigate-archive.git
```

Enter the project directory:

```bash
cd /boot/config/custom/frigate-archive
```

---

## Run the Installer

Run:

```bash
bash install.sh
```

The installer will:

- Validate required commands
- Check the project structure
- Validate the Archive Engine
- Validate the Restore Wizard
- Create runtime directories
- Create `config.conf` when required
- Check shell syntax
- Check the configured Frigate paths

The installer does not modify Frigate recordings or archived recordings.

---

## Configure Frigate Archive

Open:

```bash
nano config.conf
```

At minimum, review these settings:

```bash
SOURCE="/mnt/disks/cctv/recordings"
ARCHIVE="/mnt/user/FrigateArchive"
CONTAINER="frigate"
FRIGATE_DB="/mnt/user/appdata/frigate/frigate.db"
START_THRESHOLD=60
STOP_THRESHOLD=40
TEST_MODE=true
```

Your paths may be different.

See [Configuration](configuration.md) for a complete explanation of every setting.

---

## Run the Health Check

Before testing the archive process, run:

```bash
bash healthcheck.sh
```

A healthy installation should end with:

```text
Overall Status: HEALTHY
```

During development or before committing changes, you may see:

```text
Overall Status: HEALTHY WITH WARNINGS
```

A Git working-tree warning is normal when local files have not yet been committed.

See [Health Check](healthcheck.md) for more information.

---

## Test the Archive Engine

Keep this setting enabled:

```bash
TEST_MODE=true
```

Run:

```bash
bash archive.sh
```

Test Mode allows you to review the workflow without performing the full live archive operation.

Check:

- Storage usage detection
- Threshold evaluation
- Selected archive dates
- Log output
- Notifications
- Path validation

When you are satisfied, edit `config.conf` and set:

```bash
TEST_MODE=false
```

See [Archive Engine](archive-engine.md) for detailed usage and safety information.

---

## Test the Restore Wizard

Run:

```bash
bash restore.sh
```

The Restore Wizard will:

- Scan available archived dates
- Show file, folder, and size statistics
- Allow you to preview a restore
- Validate available recording-drive space
- Verify restored files with checksums
- Preserve the archive copy

To exit without restoring anything, select:

```text
q
```

See [Restore Wizard](restore-wizard.md) for full instructions and limitations.

---

## Schedule Automatic Archiving

Frigate Archive can be scheduled using the Unraid User Scripts plugin.

Recommended cron schedule:

```cron
0 2 * * *
```

This runs the Archive Engine every day at 2:00 AM.

The command to schedule is:

```bash
bash /boot/config/custom/frigate-archive/archive.sh
```

Do not schedule the Restore Wizard. It is intended to be run interactively.

---

## Where to Go Next

- [Installation](installation.md)
- [Configuration](configuration.md)
- [Archive Engine](archive-engine.md)
- [Restore Wizard](restore-wizard.md)
- [Health Check](healthcheck.md)
- [Troubleshooting](troubleshooting.md)
- [FAQ](faq.md)

---

## Important Restore Limitation

The Restore Wizard currently restores recording files only.

It does not recreate deleted Frigate:

- Database rows
- Timeline entries
- Review entries
- Preview images
- Recording metadata

Restored files may therefore not appear in Frigate’s normal interface unless matching metadata still exists.

---

## Getting Help

Before reporting a problem:

1. Run:

   ```bash
   bash healthcheck.sh
   ```

2. Review:

   ```text
   logs/
   ```

3. Check [Troubleshooting](troubleshooting.md).

4. Search existing GitHub issues.

---

## Related Guides

- [Installation](installation.md)
- [Configuration](configuration.md)
- [Archive Engine](archive-engine.md)
- [Restore Wizard](restore-wizard.md)
- [Health Check](healthcheck.md)
- [Troubleshooting](troubleshooting.md)
- [FAQ](faq.md)

Use the Bug Report template when opening a new issue.
