# Changelog

All notable changes to this project will be documented in this file.

The format is inspired by **Keep a Changelog**, and this project follows **Semantic Versioning** (`MAJOR.MINOR.PATCH`).

---

# [2.0.0] - 2026-07-17

## Initial Production Release

Frigate Archive V2.0.0 is the first stable production release of the project.

This version introduces a modular, safety-first archive system designed specifically for Frigate running on Unraid.

---

## Added

### Archive Management

- Automatic recording archive management
- Configurable archive thresholds
- Oldest completed day selection
- Lock file protection
- Test mode

### Transfer Engine

- High-performance `rsync` transfer engine
- Automatic destination creation
- Resume capability
- Transfer verification
- Safe deletion only after successful verification

### Database Management

- Automatic Frigate database backup
- Database synchronization
- Recording cleanup
- Timeline cleanup
- Preview cleanup
- Review segment cleanup
- SQLite VACUUM optimisation
- Automatic verification after cleanup
- Configurable backup retention

### Logging

- Comprehensive logging
- Progress reporting
- Error reporting
- Verification reporting

### Configuration

- Central configuration file
- Configurable thresholds
- Configurable backup retention
- Notification support
- Modular architecture

---

## Fixed

- Verification of existing archives
- Multi-camera archive handling
- Database cleanup reliability
- Transfer verification logic
- Archive verification logic
- Backup management
- Cleanup reporting
- Lock handling

---

## Performance

- Significantly reduced verification time
- Improved rsync performance
- Reduced database size through automatic VACUUM
- Optimised archive workflow

---

## Notes

This release has been tested with:

- Unraid
- Docker
- Frigate 0.17.x
- Multiple camera configurations
- Existing archive detection
- Archive verification
- Automatic database cleanup

---

[2.0.0]: Initial production release
