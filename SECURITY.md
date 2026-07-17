# Security Policy

## Supported Versions

The latest stable release of Frigate Archive receives security updates and fixes.

Older releases may not receive updates.

| Version | Supported |
|---------|:---------:|
| Latest Release | ✅ |
| Previous Release | ⚠️ Critical fixes only |
| Older Releases | ❌ |

---

# Reporting a Security Vulnerability

If you believe you have discovered a security vulnerability in Frigate Archive, **please do not open a public GitHub issue**.

Instead, report the vulnerability privately so it can be investigated before details become public.

Please include:

- Frigate Archive version
- Unraid version
- Frigate version
- Description of the vulnerability
- Steps to reproduce
- Potential impact
- Any suggested mitigation or fix

---

# What Happens Next

After receiving a report, the following process will be followed:

1. Confirm the report has been received.
2. Investigate the issue.
3. Determine whether the issue is reproducible.
4. Develop and test a fix if required.
5. Publish a new release if necessary.
6. Publicly disclose the issue after a fix has been released.

---

# Scope

Security reports may include issues involving:

- Archive verification
- File deletion logic
- Database handling
- Privilege escalation
- Unsafe file operations
- Command injection
- Path traversal
- Shell script vulnerabilities
- Configuration handling
- Installer behaviour

---

# Out of Scope

The following are generally outside the scope of this policy:

- Misconfigured Unraid installations
- Unsupported operating systems
- Unsupported Frigate versions
- Third-party plugins
- Vulnerabilities in Docker, Unraid, or Frigate themselves

---

# Responsible Disclosure

Please allow reasonable time for investigation and remediation before publicly disclosing any security issue.

Responsible disclosure helps protect users while fixes are developed and tested.

---

# Security Philosophy

Frigate Archive was designed with one primary objective:

> **Never risk user recordings.**

Safety is prioritised over speed and convenience.

Features that move, delete, or modify recordings are intentionally designed to verify success before making irreversible changes.

Reliability and data integrity will always take precedence over adding new functionality.

---

# Contact

Until a dedicated security contact is established, security reports may be submitted through the repository owner via GitHub.

Thank you for helping keep Frigate Archive secure.
