---
description: Automatically assign tags to Obsidian notes
argument-hint: "[folder-path] [--dry-run]"
---

# Tag Notes Command

Analyzes Obsidian notes and automatically assigns appropriate tags based on predefined criteria.

## Arguments

$ARGUMENTS

- `folder-path` (optional): Target folder path. Processes entire vault if omitted
- `--dry-run` (optional): Simulate tagging without modifying files

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

### Phase 2: Analysis & Tagging

1. Launch obsidian-tagger agents in parallel
   - **Parallel limit: 10 tasks**
   - Assign one file per agent

2. Agent invocation:
   ```
   Task tool with subagent_type="obsidian-tagger":
   "Analyze the note at [vault-path]/[file-path] and apply appropriate tags based on tag-criteria skill."
   ```

3. Repeat until all files are processed
   - Assign next file as tasks complete
   - Display progress

### Phase 3: Summary

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

- File read error: Skip and continue
- Agent failure: Skip and record in report
- Output result report even on partial success

## Example Usage

```
/tag-notes                    # Process entire vault
/tag-notes inbox              # Process inbox folder
/tag-notes notes/projects     # Process specific subfolder
/tag-notes . --dry-run        # Simulate on entire vault
```

## Notes

- Requires Obsidian MCP Tools (mcp__obsidian-mcp-tools) to be available
- Tags are added to existing tag sections or appended at file end with `---` separator
- Existing tags are preserved; duplicates are not added
