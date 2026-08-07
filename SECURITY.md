# Security Policy

## Reporting a Vulnerability

If you discover a security vulnerability in this repository, please report it responsibly.

### How to Report

1. **Do not** open a public GitHub issue for security vulnerabilities
2. Email the maintainer directly with details of the vulnerability
3. Include steps to reproduce the issue if possible
4. Allow reasonable time for a response before public disclosure

### What to Include

- Description of the vulnerability
- Steps to reproduce
- Potential impact
- Suggested fix (if any)

### Response Timeline

| Action | Timeframe |
|---|---|
| Acknowledgment of report | Within 48 hours |
| Initial assessment | Within 1 week |
| Fix or mitigation | Within 30 days (depending on severity) |

## Scope

This repository contains documentation, scripts, and templates. Security concerns may include:

- Scripts that could be exploited if run in production environments
- Sensitive information accidentally committed (API keys, credentials, internal URLs)
- Advice or commands that could cause unintended security consequences

## Best Practices for Contributors

- Never commit real credentials, API keys, or tokens
- Use placeholder values in all examples (e.g., `<api-key>`, `example.com`)
- Review scripts for injection vulnerabilities before submitting
- Ensure all example configurations follow security best practices
