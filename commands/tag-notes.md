---
description: Automatically assign tags to Obsidian notes
argument-hint: "[folder-path] [--dry-run] [--criteria <file>]"
---

# Tag Notes Command

Analyzes Obsidian notes and automatically assigns appropriate tags based on predefined criteria.

## Arguments

$ARGUMENTS

- `folder-path` (optional): Target folder path. Processes entire vault if omitted
- `--dry-run` (optional): Simulate tagging without modifying files
- `--criteria <file>` (optional): Path to tag criteria file. Defaults to `tags/_all.md`

## Workflow

### Phase 1: Discovery

1. Identify target notes (recursive)
   - If folder path specified:
     1. Use mcp__obsidian-mcp-tools__list_vault_files to get items in that folder
     2. For each subfolder found (entries ending with `/`), recursively call list_vault_files
     3. Repeat until all subfolders are processed
   - If omitted: Get all files in vault (root level, then recurse into subfolders)

2. Filter to .md files only
   - Exclude common non-note folders: `attachments/`, `.obsidian/`, `.trash/`

3. Display note list and confirm before processing

### Phase 2: Criteria Resolution

1. Parse `--criteria` argument from $ARGUMENTS

2. Locate the skill folder. Try these paths in order:
   - `./skills/tag-criteria/` (development)
   - `./.claude/skills/tag-criteria/` (project scope)
   - `~/.claude/skills/tag-criteria/` (user scope, use Bash to get home directory)

3. Load tag definitions:
   - **If `--criteria` specified**: Read the specified file
     - If path is relative, resolve from skill folder's `tags/` directory
     - If path is absolute or not found in skill folder, try as-is
   - **If `--criteria` not specified**: Read `tags/_all.md` from skill folder

4. Load `SKILL.md` from skill folder (contains Judgment Rules)

5. Combine into `full_criteria`:
   ```
   {SKILL.md content}

   ## Tag Definitions

   {tag definitions content}
   ```

### Phase 3: Analysis & Tagging

1. Launch obsidian-tagger agents in parallel
   - **Parallel limit: 10 tasks**
   - Assign one file per agent

2. Agent invocation with criteria:
   ```
   Task tool with subagent_type="obsidian-tagger":
   "Analyze the note at [vault-path]/[file-path] and apply appropriate tags.

   ---BEGIN CRITERIA---
   {full_criteria}
   ---END CRITERIA---
   "
   ```

3. Repeat until all files are processed
   - Assign next file as tasks complete
   - Display progress

### Phase 4: Summary

Output result report after processing:

```markdown
## Tagging Report

### Results

| File | Tags Added | Status |
|------|------------|--------|
| notes/example.md | #programming, #tips | Success |
| notes/meeting.md | #meeting | Success |
| notes/broken.md | - | Skipped |

### Summary

- Total processed: X files
- Success: Y files
- Skipped (no matching tags): Z files
- Total tags added: N

### Tag Distribution

| Tag | Count |
|-----|-------|
| #papers | 5 |
| #arxiv | 3 |
| ... | ... |
```

## Dry Run Mode

When `--dry-run` is specified:
- Do not modify files
- Only report tags that would be added
- Add to agent prompt: "DO NOT modify the file, only report what tags would be added"

## Error Handling

- **Criteria file not found**: Report error with tried paths and stop
- **Skill folder not found**: Report error with search paths and stop
- File read error: Skip and continue
- Agent failure: Skip and record in report
- Output result report even on partial success

## Example Usage

```
/tag-notes                              # Process entire vault with all tags
/tag-notes inbox                        # Process inbox folder
/tag-notes notes/projects               # Process specific subfolder
/tag-notes . --dry-run                  # Simulate on entire vault
/tag-notes --criteria sam-3d.md         # Use custom criteria file
/tag-notes inbox --criteria papers.md   # Process inbox with papers criteria only
```

## Notes

- Requires Obsidian MCP Tools (mcp__obsidian-mcp-tools) to be available
- Tags are added to existing tag sections or appended at file end with `---` separator
- Existing tags are preserved; duplicates are not added
- Custom criteria files should follow the same format as `tags/_all.md`
