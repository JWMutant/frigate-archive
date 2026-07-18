# Installation

This guide explains how to install Frigate Archive on Unraid and prepare it for first use.

---

## In This Guide

- System requirements
- Cloning the repository
- Running the installer
- Reviewing the configuration
- Verifying the installation
- Scheduling automatic archiving
- Updating the project
- Runtime cleanup

---

## Prerequisites

Before installing, ensure you have:

- Unraid
- Frigate running in Docker
- Git
- Bash
- Docker
- rsync

Frigate Archive is designed to run directly from the Unraid boot device and manage recordings stored elsewhere on the system.

---

## Requirements

Before installing, confirm that you have:

- Unraid
- Frigate running in Docker
- A working recording storage path
- A separate archive destination
- Access to the Frigate SQLite database
- Git
- Bash
- Docker
- rsync

You should also be comfortable using the Unraid terminal.

---

## Recommended Installation Location

The recommended project location is:

```text
/boot/config/custom/frigate-archive
```

Keeping the project under `/boot/config/custom` makes it persistent across Unraid reboots.

Because `/boot` uses a FAT filesystem, Linux executable permission bits are not retained. Run scripts with `bash`, for example:

```bash
bash install.sh
```

---

## Clone the Repository

Open an Unraid terminal and run:

```bash
cd /boot/config/custom
```

Clone the repository:

```bash
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

- Detect Unraid
- Check required commands
- Validate required project files
- Validate Archive Engine modules
- Validate Restore Wizard modules
- Create runtime directories
- Preserve an existing `config.conf`
- Create `config.conf` from the example when required
- Normalize line endings
- Validate shell syntax
- Check configured paths
- Check the Frigate container
- Check the Frigate database

The installer does not:

- Delete recordings
- Move recordings
- Modify the Frigate database
- Start an archive operation
- Start a restore operation

---

## Create or Review the Configuration

If `config.conf` does not already exist, the installer creates it from:

```text
config.conf.example
```

Open the configuration:

```bash
nano config.conf
```

At minimum, review:

```bash
SOURCE="/mnt/disks/cctv/recordings"
ARCHIVE="/mnt/user/FrigateArchive"
CONTAINER="frigate"
FRIGATE_DB="/mnt/user/appdata/frigate/frigate.db"

START_THRESHOLD=60
STOP_THRESHOLD=40

TEST_MODE=true
```

Your paths and container name may be different.

See [Configuration](configuration.md) for full details.

---

## Run the Health Check

After installation, run:

```bash
bash healthcheck.sh
```

A fully healthy installation should end with:

```text
Overall Status: HEALTHY
```

A warning about uncommitted Git changes may appear while developing or editing local files.

See [Health Check](healthcheck.md) for details.

---

## Test the Archive Engine

Keep:

```bash
TEST_MODE=true
```

Run:

```bash
bash archive.sh
```

Review:

- Detected storage usage
- Threshold evaluation
- Selected archive dates
- Paths
- Log output
- Notifications
- Any warnings

When satisfied, edit `config.conf`:

```bash
nano config.conf
```

Then set:

```bash
TEST_MODE=false
```

---

## Test the Restore Wizard

Run:

```bash
bash restore.sh
```

The Restore Wizard will list valid archived dates.

To exit without restoring anything, enter:

```text
q
```

Do not schedule `restore.sh`. It is intended to be interactive.

---

## Schedule Automatic Archiving

Use the Unraid User Scripts plugin.

Create a script that runs:

```bash
bash /boot/config/custom/frigate-archive/archive.sh
```

Recommended cron schedule:

```cron
0 2 * * *
```

This runs every day at 2:00 AM.

---

## Updating an Existing Installation

Enter the project directory:

```bash
cd /boot/config/custom/frigate-archive
```

Check for local changes:

```bash
git status
```

Pull the latest changes:

```bash
git pull
```

Run the installer again:

```bash
bash install.sh
```

The installer preserves an existing `config.conf`.

Always review the changelog before updating:

```text
CHANGELOG.md
```

---

## Uninstalling Runtime Files

Run:

```bash
bash uninstall.sh
```

The cleanup utility can remove:

- Archive logs
- Restore logs
- Project database backups
- Archive locks
- Restore locks
- Optionally, `config.conf`

It preserves:

- Frigate
- Live recordings
- Archived recordings
- Frigate database
- Archive Engine source code
- Restore Wizard source code
- Project source code

To completely remove the project, manually delete the project directory only after confirming you no longer need it.

---

## Verification Checklist

After installation, confirm:

- [ ] `config.conf` exists
- [ ] Recording path is correct
- [ ] Archive path is correct
- [ ] Frigate container name is correct
- [ ] Frigate database path is correct
- [ ] `bash healthcheck.sh` passes
- [ ] `bash archive.sh` works in Test Mode
- [ ] `bash restore.sh` displays archived dates
- [ ] Automatic archiving is scheduled only after testing

---

## Next Steps

- [Configuration](configuration.md)
- [Archive Engine](archive-engine.md)
- [Restore Wizard](restore-wizard.md)
- [Health Check](healthcheck.md)
- [Troubleshooting](troubleshooting.md)

---

## Related Guides

- [Installation](installation.md)
- [Configuration](configuration.md)
- [Archive Engine](archive-engine.md)
- [Restore Wizard](restore-wizard.md)
- [Health Check](healthcheck.md)
- [Troubleshooting](troubleshooting.md)
- [FAQ](faq.md)
