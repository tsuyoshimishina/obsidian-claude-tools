---
description: Apply Japanese formatting rules to Obsidian notes
argument-hint: "<file-path|folder-path> [--dry-run]"
---

# Format Japanese Note Command

Applies consistent Japanese formatting rules to Obsidian notes.

## Arguments

$ARGUMENTS

- `file-path` or `folder-path` (required): Target file or folder path
- `--dry-run` (optional): Preview changes without modifying files

## Formatting Rules

### Rule 1: Half-width Colon to Full-width Colon

**Target conversions:**
- After bold items: `**Item**:` → `**Item**：`
- List item separators: `- **MoE3D**: desc` → `- **MoE3D**：desc`
- In headings: `## Notes: Title` → `## Notes：Title`

**Space insertion after full-width colon:**

When the converted full-width colon is followed by URL or Markdown/Obsidian syntax, insert a half-width space for readability:

| Before | After | Reason |
|--------|-------|--------|
| `**GitHub**：https://...` | `**GitHub**： https://...` | URL follows |
| `**参照**：[[note]]` | `**参照**： [[note]]` | Obsidian internal link |
| `**埋込**：![[image]]` | `**埋込**： ![[image]]` | Obsidian embed |
| `**リンク**：[text](url)` | `**リンク**： [text](url)` | Markdown link |
| `**コード**：\`example\`` | `**コード**： \`example\`` | Inline code |

**Patterns requiring space after `：`:**
- `https://`, `http://`, `ftp://` (URLs)
- `[[` (Obsidian internal link)
- `![[` (Obsidian embed)
- `[` followed by text and `](` (Markdown link)
- `` ` `` (inline code start)

**Exclusions:**
- URLs: `https://`, `http://` (do not convert the colon in URL schemes)
- arXiv IDs: `arXiv:2601.04090`
- Code blocks (fenced with ```)
- Inline code (wrapped with `)

### Rule 2: Space Insertion at Half-width/Full-width Boundaries

**Target conversions:**

| Pattern | Before | After |
|---------|--------|-------|
| ASCII → Japanese | `VGGTは` | `VGGT は` |
| Japanese → ASCII | `モデルVGGT` | `モデル VGGT` |
| Number → Japanese | `3D生成` | `3D 生成` |
| Japanese → Number | `レベルの3D` | `レベルの 3D` |
| Number → Counter | `1枚` | `1 枚` |

**Exclusions:**
- Before/after parentheses: `（VGGT）と` - no space needed
- URLs: `https://xdimlab.github.io/Gen3R/`
- Tags: `#3d-reconstruction` (no space after #)
- Code blocks/inline code
- Markdown syntax boundaries: `**text**の` - no space between `**` and `の`

**Character class regex:**
```
Half-width alphanumeric: [A-Za-z0-9]
Hiragana: [\u3040-\u309F]
Katakana: [\u30A0-\u30FF]
Kanji: [\u4E00-\u9FFF]
```

### Rule 3: Half-width Parentheses to Full-width Parentheses

**Target conversions:**
- In Japanese text: `(説明)` → `（説明）`
- Date expressions: `(2026年1月)` → `（2026 年 1 月）`
- English content too: `(geometric latents)` → `（geometric latents）`

**Exclusions:**
- URLs
- Code blocks/inline code
- Markdown link syntax: `[text](url)` - do not convert the URL parentheses

## Workflow

### Phase 1: Discovery

1. Parse arguments from $ARGUMENTS
   - Extract file/folder path
   - Check for `--dry-run` flag

2. Identify target files:
   - **If file path (.md)**: Process single file
   - **If folder path**:
     1. Use mcp__obsidian-mcp-tools__list_vault_files to get items
     2. Recursively process subfolders (entries ending with `/`)
     3. Filter to .md files only

3. Exclude common non-note folders: `attachments/`, `.obsidian/`, `.trash/`

4. Display file list and confirm before processing

### Phase 2: Processing

For each target file:

1. **Read file content**
   - Use mcp__obsidian-mcp-tools__get_vault_file with format="markdown"

2. **Identify exclusion zones** (track character positions)
   - Code blocks: Match ``` to closing ```
   - Inline code: Match ` to closing `
   - URLs: Match `https?://[^\s)\]]+`
   - Markdown links: Match `[text](url)` - protect the url portion
   - arXiv IDs: Match `arXiv:\d+\.\d+`

3. **Apply rules in order** (outside exclusion zones only)
   - **Rule 3 first** (parentheses): `(` → `（`, `)` → `）`
     - Skip if already full-width
     - Skip if inside exclusion zone
   - **Rule 2 second** (spacing): Insert space at boundaries
     - Pattern: `([A-Za-z0-9])([\u3040-\u309F\u30A0-\u30FF\u4E00-\u9FFF])` → `$1 $2`
     - Pattern: `([\u3040-\u309F\u30A0-\u30FF\u4E00-\u9FFF])([A-Za-z0-9])` → `$1 $2`
     - Skip if space already exists
     - Skip if at parenthesis boundary (full-width or half-width)
     - Skip if inside exclusion zone
   - **Rule 1 last** (colon): `:` → `：`
     - Skip if inside exclusion zone
     - Skip if preceded by `http`, `https`, `arXiv`, or other URL schemes
     - After conversion, check if followed by URL/Markdown/Obsidian syntax:
       - If `：` is followed by `http`, `https`, `ftp`, `[[`, `![[`, `[`, or `` ` ``: insert space
       - Pattern: `：(https?://|ftp://|\[\[|!\[\[|\[|` `)` → `： $1`

4. **Compare original vs modified**
   - Track changed lines for reporting

5. **Save changes** (unless --dry-run)
   - Use mcp__obsidian-mcp-tools__create_vault_file to overwrite

### Phase 3: Summary

Output result report:

```markdown
## Formatting Report

### Changes

| File | Changes | Status |
|------|---------|--------|
| inbox/note.md | 15 replacements | Success |
| inbox/other.md | 0 replacements | No changes |

### Summary

- Total processed: X files
- Modified: Y files
- No changes: Z files
- Total replacements: N

### Sample Changes (first file with changes)

| Line | Before | After |
|------|--------|-------|
| 5 | `**GitHub**: https://...` | `**GitHub**： https://...` |
| 8 | `**参照**: [[note]]` | `**参照**： [[note]]` |
| 12 | `VGGTは` | `VGGT は` |
| 18 | `(2026年1月)` | `（2026 年 1 月）` |
```

## Dry Run Mode

When `--dry-run` is specified:
- Do NOT modify any files
- Report all changes that would be made
- Show detailed before/after comparisons

## Error Handling

- **File not found**: Report error and stop
- **Folder not found**: Report error and stop
- **File read error**: Skip file and continue
- **File write error**: Report error and continue with next file
- Output result report even on partial success

## Example Usage

```
/format-japanese-note inbox/note.md              # Format single file
/format-japanese-note inbox                      # Format all files in inbox
/format-japanese-note inbox/note.md --dry-run   # Preview changes
/format-japanese-note . --dry-run               # Preview changes for entire vault
```

## Important Notes

- Original files are overwritten - backup important files first
- Preserves Markdown structure (links, code blocks)
- Does not insert duplicate spaces
- Requires Obsidian MCP Tools (mcp__obsidian-mcp-tools) to be available
