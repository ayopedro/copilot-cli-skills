# Copilot CLI Skills Repo

This repository stores custom Copilot CLI skills and related configuration in one place.

## Contents

- `copilot/skills/pr-summary/SKILL.md`
- `copilot/skills/security-remediation-pr/SKILL.md`
- `copilot/config/config.json`
- `copilot/config/mcp-config.json`
- `copilot/config/permissions-config.json`
- `copilot/config/settings.json`

## Install the skills locally

Run the installer to copy the skills into your local Copilot directory:

```bash
./install-skills.sh
```

By default, the script installs into `~/.copilot/skills`. You can pass a different destination path as the first argument:

```bash
./install-skills.sh "$HOME/.copilot/skills"
```

## Notes

- Review config files before publishing this repo.
- Keep the repository private if configs contain account-specific settings.
