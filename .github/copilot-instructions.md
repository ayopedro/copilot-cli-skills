# Copilot Instructions

This repository stores reusable Copilot CLI skills and related config.

## Skill conventions

- Keep each skill in `copilot/skills/<skill-name>/SKILL.md`.
- Use kebab-case for skill folder names.
- Keep skill descriptions focused and actionable.

## Installer conventions

- `install-skills.sh` must support installing all skills and selected skills.
- When adding a new skill folder, keep installer behavior compatible without extra hardcoded entries.
- Update `README.md` usage examples when installer options change.

## Safety and scope

- Prefer minimal, targeted changes.
- Do not modify unrelated skills/config files in the same change.
