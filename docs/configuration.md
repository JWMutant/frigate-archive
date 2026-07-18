# Configuration

Configure Frigate Archive for your environment.

> **Documentation Version:** v2.3.0  
> Applies to Frigate Archive v2.2.0 and later.

---

## In This Guide

- Configuration overview
- The `config.conf` file
- Required settings
- Archive thresholds
- Test Mode
- Best practices
- Common mistakes

---

## Prerequisites

Before editing the configuration, ensure you have:

- Installed Frigate Archive
- Successfully run `install.sh`
- A working Frigate installation
- Access to your recording and archive storage

---

# Configuration Overview

All user-configurable settings are stored in:

```text
config.conf
```

This file controls:

- Recording locations
- Archive locations
- Frigate database access
- Storage thresholds
- Container information
- Logging behaviour
- Safety features

The installer creates `config.conf` automatically if it does not already exist.

---

# Opening the Configuration

Open the configuration file:

```bash
nano config.conf
```

---

# Example Configuration

```bash
SOURCE="/mnt/disks/cctv/recordings"
ARCHIVE="/mnt/user/FrigateArchive"

CONTAINER="frigate"

FRIGATE_DB="/mnt/user/appdata/frigate/frigate.db"

START_THRESHOLD=60
STOP_THRESHOLD=40

TEST_MODE=true
```

Your paths may differ depending on your Unraid installation.

---

# Configuration Options

## SOURCE

```bash
SOURCE="/mnt/disks/cctv/recordings"
```

The location of Frigate's live recordings.

This is where the Archive Engine searches for completed recordings.

### Recommended

Use the storage location mounted into the Frigate container.

---

## ARCHIVE

```bash
ARCHIVE="/mnt/user/FrigateArchive"
```

The destination for archived recordings.

### Recommended

Use a parity-protected array share rather than a cache drive.

---

## CONTAINER

```bash
CONTAINER="frigate"
```

The Docker container name used by Frigate.

This is used when stopping and starting Frigate during archive operations.

Check the container name with:

```bash
docker ps
```

---

## FRIGATE_DB

```bash
FRIGATE_DB="/mnt/user/appdata/frigate/frigate.db"
```

Path to the Frigate SQLite database.

The Archive Engine updates this database after successful archive operations.

Do not modify this value unless you know the correct database location.

---

# Storage Thresholds

## START_THRESHOLD

```bash
START_THRESHOLD=60
```

The archive process begins when recording storage reaches this percentage.

Example:

Recording drive reaches **60%** utilisation.

↓

Archive begins.

---

## STOP_THRESHOLD

```bash
STOP_THRESHOLD=40
```

Archiving continues until usage falls below this percentage.

Example:

Recording drive drops to **40%**.

↓

Archive stops.

---

# Why Two Thresholds?

Using separate start and stop thresholds prevents the archive process from repeatedly starting and stopping when storage usage fluctuates around a single value.

This behaviour is known as **hysteresis** and helps reduce unnecessary archive operations.

---

# Test Mode

```bash
TEST_MODE=true
```

Test Mode allows you to safely verify the archive workflow without moving recordings or modifying the Frigate database.

### Recommended

Always leave Test Mode enabled during initial setup.

When you are satisfied that everything is working correctly:

```bash
TEST_MODE=false
```

---

# Best Practices

- Keep recordings on fast SSD or cache storage.
- Store archives on protected array storage.
- Run the Health Check after making configuration changes.
- Test using `TEST_MODE=true` before enabling live archiving.
- Schedule only `archive.sh` for automatic execution.
- Run `restore.sh` manually when required.

---

# Common Mistakes

## Incorrect recording path

Verify:

```bash
ls "$SOURCE"
```

---

## Incorrect archive destination

Verify:

```bash
ls "$ARCHIVE"
```

---

## Incorrect container name

Check:

```bash
docker ps
```

---

## Incorrect database path

Verify:

```bash
ls "$FRIGATE_DB"
```

---

## Test Mode left enabled

If no recordings are being archived, confirm:

```bash
TEST_MODE=false
```

when you are ready for production.

---

# Validation

After changing the configuration, run:

```bash
bash healthcheck.sh
```

Then perform a Test Mode archive:

```bash
bash archive.sh
```

Confirm that:

- Health Check passes
- Paths are correct
- Archive dates are detected
- No unexpected warnings are reported

---

## Related Guides

- [Getting Started](getting-started.md)
- [Installation](installation.md)
- [Archive Engine](archive-engine.md)
- [Restore Wizard](restore-wizard.md)
- [Health Check](healthcheck.md)
- [Troubleshooting](troubleshooting.md)
- [FAQ](faq.md)
