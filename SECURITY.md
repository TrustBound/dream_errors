# Security Policy

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| 1.x     | ✅ Active support  |

## What dream_errors Is

dream_errors is one Gleam type and four pure functions. It reads no files, opens no connections, and writes no logs.

## What dream_errors Is Responsible For

- **The type and the functions**: they do what their docs say, and nothing else.
- **The docs**: they tell you that the `message` of an error is for developers and logs only.

## What You Are Responsible For

- **The message**: a package can put table names, hosts, keys or parts of the input in the `message`. Never show it to the users of your app, and never put it in an HTTP response.
- **The cause**: the cause is the package's own error. It can hold the same data. Treat it like the message.
- **Your logs**: who can read them, and how long you keep them.

## Reporting a Vulnerability

**Do not report security vulnerabilities through public GitHub issues.**

Email: **engineering@trustbound.ai**

### What to Include

- **Type of vulnerability**
- **Location** in dream_errors's code (file and function)
- **Steps to reproduce** with a minimal example
- **Impact**: what can an attacker do?
- **Proof of concept** if you have one

Report vulnerabilities in **dream_errors's code**, not in your application code or in the package that made the error.

### What to Expect

1. **Acknowledgment** within 48 hours
2. **Assessment** within 7 days
3. **Fix** coordinated with you on timing
4. **Release** with a security advisory
5. **Credit** in the advisory, if you want it

## Known Non-Issues

These are not dream_errors vulnerabilities:

- A message or a cause that your app shows to its users or writes to a response.
- Data in a message or a cause that another package put there. Report it to that package.

## Dependencies

- **gleam_stdlib**

## Questions?

- **Security questions**: engineering@trustbound.ai
- **Other issues**: [GitHub Issues](https://github.com/TrustBound/dream_errors/issues)
- **General discussion**: [GitHub Discussions](https://github.com/TrustBound/dream/discussions)
