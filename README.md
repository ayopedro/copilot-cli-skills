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

Run the installer to copy the skills into your local Copilot directory.  
If no mode is provided, the script prompts you to install all skills or select specific ones:

```bash
./install-skills.sh
```

Install all skills explicitly:

```bash
./install-skills.sh --all
```

Install only selected skills:

```bash
./install-skills.sh --skills pr-summary,security-remediation-pr
```

By default, the script installs into `~/.copilot/skills`. You can pass a different destination path as the first argument, or with `--destination`:

```bash
./install-skills.sh "$HOME/.copilot/skills"
./install-skills.sh --destination "$HOME/.copilot/skills" --all
```

## Notes

- Review config files before publishing this repo.
- Keep the repository private if configs contain account-specific settings.
