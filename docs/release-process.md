# Release Process

This project uses a simple GitHub flow.

---

## Branch Strategy

```text
main = stable releases
feature/* = new features
fix/* = bug fixes
```

Examples:

```text
feature/exchange-online-collector
feature/v0.4-quality-reporting
fix/report-html-escaping
```

---

## Development Workflow

1. Start from `main`.
2. Create a feature branch.
3. Make changes.
4. Run tests.
5. Commit and push the branch.
6. Open a Pull Request.
7. Merge into `main` after validation.
8. Create a tag and GitHub Release.

---

## Versioning

Use semantic-style versioning while the project is pre-1.0:

```text
v0.2.0 = Microsoft Graph live collector
v0.3.0 = Exchange Online live collector
v0.4.0 = quality, testing, and reporting improvements
v0.5.0 = safer live mode and UX improvements
v0.8.0 = remediation, sanitized export, and GitHub Pages demo
v1.0.0 = first stable public release with complete documentation and release-ready project structure
```

Patch versions are used for fixes after a release:

```text
v0.3.1 = bug fix after v0.3.0
```

---

## Creating a Tag

```bash
git tag -a v0.4.0 -m "EntraShield v0.4.0 - Quality and reporting improvements"
git push origin v0.4.0
```

If using the GitHub website, create the tag while drafting the release and target `main`.

---

## Release Checklist

Before publishing a release:

- [ ] Module imports without parser errors
- [ ] Demo audit runs successfully
- [ ] Pester tests pass
- [ ] README updated
- [ ] CHANGELOG updated
- [ ] No real tenant reports committed
- [ ] Version updated in `src/EntraShield.psd1`
- [ ] Release notes prepared

---

## Release Notes Template

```text
## EntraShield vX.Y.Z - Title

Added:
- ...

Changed:
- ...

Fixed:
- ...

Notes:
- ...
```
