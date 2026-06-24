---
name: pr-summary
description: "ALWAYS invoke this skill before creating or opening a pull request. Generates the PR title, body, and description from the branch diff. Also use when: updating/refreshing an existing PR description, summarizing what changed for reviewers, or producing markdown reviewer context from changed files. The output of this skill must be used as the PR body when creating or updating a PR. Archive file creation should be opt-in by user confirmation unless explicitly requested."
parameters:
  - name: focus_areas
    type: string
    required: false
    description: "Comma-separated list of focus areas (e.g., 'performance,security,infrastructure,testing'). If omitted, uses default sections."
  - name: scope
    type: string
    required: false
    description: "Limit analysis to specific path (e.g., 'src/api' or current file). If omitted, analyzes entire repository."
  - name: exclude_archive
    type: boolean
    required: false
    default: false
    description: "If true, display summary only without archiving to markdown file."
  - name: archive_mode
    type: string
    required: false
    default: "ask"
    description: "Archive behavior: 'ask' (default, ask user before saving), 'always' (save automatically), 'never' (do not save)."
---

# PR Summary Agent

Generate polished pull request summaries with customizable sections, automatic branching logic, and optional archival.

## Invocation Triggers

**MANDATORY**: Always invoke this skill before creating or opening a pull request — even when the user does not explicitly ask for a summary. The generated description must be used as the PR body.

Also invoke when the user asks to:

- Create/open/raise a PR and needs a description or summary
- Update/refresh/rewrite an existing PR description after changes
- Summarize what changed in the branch for PR reviewers
- Produce PR notes/changelog-style markdown from git diffs

Common intent phrases:
- "create a PR", "open a PR", "raise a pull request", "make a PR", "submit a PR"
- "commit and PR", "push and open a PR", "push a PR"
- "update the PR", "refresh PR description", "rewrite PR body"
- "summarize this PR", "write PR notes", "what changed in this branch"

## Capabilities

- **Automatic branch detection**: Discovers default branch (main/master/develop) without user input
- **Scoped analysis**: Can focus on specific directories or files within the repo
- **Customizable sections**: Support for domain-specific focus areas (security, performance, infrastructure, testing, etc.)
- **Timestamped archival**: Saves summaries to `pull_request_summaries/` with branch name and timestamp
- **Formatted output**: Markdown with overview, key changes, impact analysis, and recommendations

## Workflow

1. **Detect git context**: Identify current branch, default branch, and workspace root
2. **Gather diffs**: Retrieve file change statistics and detailed diffs
3. **Scope analysis**: Filter to specified directory/file or analyze full repo
4. **Structure content**: Build summary sections based on focus areas or defaults
5. **Format markdown**: Create comprehensive summary document
6. **Present options to user**: Before archival in `archive_mode='ask'`, clearly list available options so the user can choose behavior.
7. **Archive decision**: If `exclude_archive=true` or `archive_mode='never'`, display in chat only. If `archive_mode='always'`, save to file. Otherwise ask the user whether they want to archive before saving.
8. **Use as PR body**: Pass the generated summary as the `body` argument when calling the PR creation tool

### Ask Mode Prompt Template

When `archive_mode='ask'` and the user did not explicitly set preferences, provide a short options prompt like:

- Archive options: `save summary file`, `chat-only (no file)`
- Scope options: `full repo` or `specific path`
- Focus options: `default sections` or custom focus areas such as `security`, `performance`, `testing`, `infrastructure`

Then proceed based on the user's choice.

## Usage Examples

### Standard summary (full repo, default sections)
```
/pr-summary
```

### Security-focused analysis
```
/pr-summary focus_areas="security,compliance"
```

### Infrastructure changes only
```
/pr-summary scope="terraform" focus_areas="infrastructure"
```

### Chat-only display (no archival)
```
/pr-summary exclude_archive=true
```

### Ask mode (default interactive choice)
```
/pr-summary archive_mode="ask"
```

### Specific directory with custom sections
```
/pr-summary scope="src/api" focus_areas="performance,testing,api-design"
```

## Default Sections

When no custom `focus_areas` specified:
- **Overview**: High-level summary of PR scope
- **Key Changes**: Detailed breakdown of modifications by file
- **Impact**: Effects on system behavior, performance, compatibility
- **Testing Recommendations**: Suggested validation steps
- **Files Modified**: File list with change statistics

## Output Format

If archived (user opted in or `archive_mode='always'`): `./pull_request_summaries/{BRANCH_NAME}-{TIMESTAMP}.md`

Example filename: `CAE-1844-2026-06-15T09-54-13Z.md`

### Metadata
- Branch name, comparison target (default branch)
- Commit range and file statistics
- Generation timestamp

### Content
- Structured sections matching focus areas
- Clear impact analysis
- Actionable testing/review guidance
- Code snippets for significant changes (optional)

## Custom Focus Areas

Suggested options:
- `performance` - Optimization, algorithmic changes, resource usage
- `security` - Authentication, authorization, vulnerability fixes
- `infrastructure` - Cloud resources, networking, deployment
- `testing` - Test coverage, test additions/removals
- `documentation` - README, comments, API docs
- `database` - Schema changes, migration scripts
- `api-design` - Endpoint changes, contract modifications
- `ui-ux` - User interface, experience changes
- `compliance` - Regulatory, standards alignment

Combine multiple: `focus_areas="security,performance,infrastructure"`

## Best Practices

1. **Ask before archival**: Default to asking the user whether to save the summary file
2. **Consistent naming**: Use `.gitignore` to exclude `pull_request_summaries/` from repos if not needed in version control
3. **Focus for clarity**: Use `focus_areas` to create targeted summaries for specific audiences (architects, QA, security)
4. **Scope for large repos**: For monorepos, specify `scope` to prevent overly large summaries
5. **Team coordination**: Consider standardizing which focus areas and formats your team uses

## Related Workflows

- **Pre-commit validation**: Generate summary before pushing to confirm scope aligns with branch purpose
- **Async code review**: Archive summary with PR for reviewer context
- **Change log generation**: Collect multiple summaries for release notes
- **Impact analysis**: Use security/performance focus for high-risk changes
