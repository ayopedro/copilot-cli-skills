---
name: security-remediation-pr
description: "End-to-end workflow for GitHub Security/CodeQL remediation: review open alerts, create a focused fix branch, implement and validate fixes, then open a PR with a reviewer-ready body."
parameters:
  - name: base_branch
    type: string
    required: false
    description: "Target branch for remediation PRs (defaults to repo default branch or current feature branch as appropriate)."
  - name: max_alerts
    type: number
    required: false
    default: 5
    description: "Maximum open alerts to process in one run."
  - name: severity_filter
    type: string
    required: false
    default: "critical,high,medium,warning"
    description: "Comma-separated severities to include."
  - name: tool_filter
    type: string
    required: false
    default: "CodeQL"
    description: "Security scanner/tool to prioritize (e.g., CodeQL, SnykCode)."
  - name: branch_prefix
    type: string
    required: false
    default: "fix/security"
    description: "Prefix for the remediation branch name."
  - name: create_pr
    type: boolean
    required: false
    default: true
    description: "If true, push branch and create PR after fixes are complete."
  - name: include_dismissed
    type: boolean
    required: false
    default: false
    description: "If true, include dismissed alerts for audit/revalidation only; do not reopen or edit them."
---

# Security Remediation PR Skill

Use this skill when the user asks to investigate items in the **Security** or **Code Quality** tab and wants a clean, review-ready remediation branch and PR.

## Primary Outcome

Deliver a branch that:
1. Fixes selected **open** security/code scanning alerts at source.
2. Preserves existing behavior unless a security-safe change is required.
3. Includes a clear PR with impact and testing notes.

## Invocation Triggers

Invoke when user intent includes:
- "security concerns in Security/Quality tab"
- "check CodeQL/Snyk alerts"
- "fix security findings"
- "create branch for security fixes"
- "open PR for security remediation"

## Guardrails

- Prioritize **open** alerts; treat dismissed/fixed alerts as context only.
- Fix root causes, not superficial suppressions.
- Do not add blanket try/catch blocks, silent fallbacks, or broad bypasses.
- Keep fixes scoped to alert-relevant paths unless tightly coupled changes are required.
- If remediation requires behavior changes, state it explicitly in PR impact notes.

## Workflow

1. **Collect security findings**
   - Use `gh api repos/{owner}/{repo}/code-scanning/alerts`.
   - Filter to `state=open` (plus optional filters: tool, severity).
   - Capture: alert number, rule id, severity, location path/line, URL.

2. **Choose remediation scope**
   - Process up to `max_alerts` in one pass.
   - Group findings by rule and file to minimize fragmented edits.
   - If findings are unrelated and large, ask user whether to split into multiple PRs.

3. **Create dedicated branch**
   - Name pattern: `{branch_prefix}-{topic}-{yyyymmdd}`.
   - Branch from `base_branch` if provided; otherwise from current working branch strategy agreed with user.

4. **Implement fixes**
   - Read nearby code and identify existing helpers/patterns before adding new logic.
   - Apply targeted fixes directly at vulnerable routes/functions.
   - Prefer established libraries for security controls (e.g., rate limiting, input validation, sanitization).

5. **Validate changes**
   - Run smallest existing lint/test commands covering touched behavior.
   - Escalate only if targeted checks fail or are insufficient.

6. **Prepare PR-ready commit(s)**
   - Stage only remediation-related files.
   - Use clear commit message: `fix(security): <short description>`.
   - Include co-author trailer if policy requires it.

7. **Create PR body (mandatory)**
   - Invoke `pr-summary` before PR creation.
   - Ensure PR body includes:
     - Findings addressed (rule + file/path context)
     - Security impact
     - Behavioral impact
     - Validation notes
     - Files changed

8. **Open PR**
   - Push branch and create PR via `gh pr create`.
   - Title format: `fix(security): remediate <rule/topic> findings`.

## PR Content Template (Minimum)

```markdown
## Overview
Remediates open security/code scanning findings for <rule/topic>.

## Findings Addressed
- <rule-id> in <file>:<line> (alert #<n>)

## Key Changes
- <what was changed and where>

## Impact
- Security: <risk reduced>
- Runtime/behavior: <none or explicit change>

## Validation
- <lint/test commands used>

## Files Modified
- <path>
```

## Decision Rules

- If alert points to missing controls on public routes, add scoped middleware (e.g., route-level rate limit).
- If alert indicates input trust issues, enforce validation before use and sanitize outputs where needed.
- If alert cannot be safely fixed without product decisions, stop and ask one focused question with options.

## Example Invocations

- `/security-remediation-pr`
- `/security-remediation-pr severity_filter="high,critical" max_alerts=3`
- `/security-remediation-pr base_branch="develop" tool_filter="CodeQL" create_pr=true`

