# Frequently Asked Questions (FAQ)

Answers to the questions most commonly asked by Frigate Archive users.

These questions are based on real-world installation, configuration, testing, and development experience.

> **Documentation Version:** v2.3.0  
> Applies to Frigate Archive v2.2.0 and later.

---

## In This Guide

- General
- Installation
- Archive Engine
- Restore Wizard
- Health Check
- Configuration
- Troubleshooting
- Development

---

# General

## What is Frigate Archive?

Frigate Archive is a toolkit for managing Frigate recordings on Unraid.

It provides:

- Automatic archiving
- Safe restoration
- Health validation
- Installation assistance
- Runtime cleanup

---

## Why was Frigate Archive created?

Frigate records continuously to fast storage.

Eventually that storage fills up.

Frigate Archive automatically moves completed recordings to long-term storage while helping keep Frigate's recording storage available.

---

## What makes Frigate Archive different from simply copying files?

Frigate Archive is designed around data integrity.

It performs:

- Verification before deletion
- Database cleanup
- Runtime validation
- Health checks
- Restore verification
- Detailed logging

rather than simply moving files.

---

# Installation

## Where should I install Frigate Archive?

The recommended location is:

```text
/boot/config/custom/frigate-archive
```

This location persists across Unraid reboots.

---

## Can I install it somewhere else?

Yes.

However, all documentation assumes the recommended installation location.

---

## Does the installer overwrite my configuration?

No.

Existing `config.conf` files are preserved.

---

# Archive Engine

## Why are there two storage thresholds?

Using separate START and STOP thresholds prevents the Archive Engine repeatedly starting and stopping when storage usage fluctuates around a single percentage.

This behaviour is known as **hysteresis**.

---

## Why doesn't the archive start immediately?

The Archive Engine waits until the recording drive reaches `START_THRESHOLD`.

This avoids unnecessary archive operations.

---

## What happens if verification fails?

Original recordings remain untouched.

The archive operation stops safely.

No recordings are deleted until verification succeeds.

---

## Why does Frigate stop during an archive?

Stopping Frigate helps prevent files from changing while they are being archived, reducing the risk of inconsistent or incomplete transfers.

---

# Restore Wizard

## Why doesn't the Restore Wizard recreate Frigate database entries?

The current Restore Wizard restores recording files only.

Database restoration is planned for a future version.

---

## Why are archive copies preserved?

The archive always remains the authoritative copy.

Keeping archived recordings allows them to be restored again if required.

---

## Can I restore multiple archive dates?

Currently, restores are performed one archive date at a time.

---

## Can I schedule the Restore Wizard?

No.

The Restore Wizard is intentionally interactive and should only be run manually.

---

# Health Check

## What does "HEALTHY WITH WARNINGS" mean?

The project is operational, but one or more non-critical warnings were detected.

Examples include:

- Uncommitted Git changes
- Optional components
- Development environment notices

---

## Should I worry about warnings?

Warnings should be reviewed, but they do not necessarily prevent Frigate Archive from operating correctly.

Failures should always be resolved before using the project.

---

## Why does Health Check report Git warnings?

During development it is normal to have local changes that have not yet been committed.

This warning is informational.

---

# Configuration

## Can I archive directly to a NAS?

Yes, provided the NAS is mounted and accessible from Unraid.

Performance depends on your network and storage.

---

## Can I archive to another internal disk?

Yes.

Any mounted storage location can be used as the archive destination.

---

## Can I change the archive thresholds?

Yes.

Modify:

```text
START_THRESHOLD

STOP_THRESHOLD
```

within `config.conf`.

---

# Troubleshooting

## The archive never starts.

Check:

- Recording storage usage
- START_THRESHOLD
- TEST_MODE
- Health Check results

---

## Restore Wizard cannot find archived recordings.

Verify:

- ARCHIVE path
- Permissions
- Archived recordings exist

---

## Health Check reports failures.

Resolve all reported failures before continuing.

The Health Check output usually identifies the failing component.

---

## Test Mode appears to do nothing.

Test Mode intentionally prevents live archive operations.

It allows you to safely verify configuration and workflow before enabling production mode.

---

## Storage statistics appear incorrect.

Run the Archive Engine again after database cleanup.

If the problem persists, review the Health Check and logs before opening an issue.

---

# Development

## Why is the project modular?

Splitting functionality into modules makes the project easier to understand, maintain, test, and extend.

---

## Why is Frigate Archive written in Bash?

Bash is available by default on Unraid, making deployment simple without requiring additional runtime dependencies.

---

## Is Frigate Archive only for Unraid?

The project is currently designed and tested specifically for Unraid.

Other Linux distributions may work but are not officially supported.

---

## What is planned for Version 3?

Current goals include:

- Shared `modules/common/` framework
- Improved code reuse
- Additional restore capabilities
- Expanded automated testing
- Continued documentation improvements

---

## Didn't find your question?

Search the existing GitHub Issues and Discussions.

If your question still isn't answered, please open a new GitHub Issue using the appropriate template.

---

## Related Guides

- [Getting Started](getting-started.md)
- [Installation](installation.md)
- [Configuration](configuration.md)
- [Archive Engine](archive-engine.md)
- [Restore Wizard](restore-wizard.md)
- [Health Check](healthcheck.md)
- [Troubleshooting](troubleshooting.md)
- [Developer Guide](developer-guide.md)
