# Obsidian Claude Tools

A collection of Claude Code plugins for enhancing Obsidian workflows.

## Overview

This project provides tools that integrate Obsidian with Claude Code, enabling AI-assisted note management and automation. Each tool is implemented as a Claude Code plugin with slash commands, agents, and skills.

## Available Tools

### Auto-Tagger (`/tag-notes`)

Automatically assigns tags to Obsidian notes based on their content.

**Features:**
- Assigns tags from predefined categories that clearly match note content
- Fast batch processing with parallel execution (up to 10 concurrent)
- Dry-run mode for simulation
- Preserves existing tags while adding new ones

**Usage:**
```
/tag-notes                              # Process entire vault
/tag-notes inbox                        # Process inbox folder
/tag-notes notes/projects               # Process specific subfolder
/tag-notes . --dry-run                  # Simulate on entire vault
/tag-notes --criteria custom.md         # Use custom criteria file
/tag-notes inbox --criteria papers.md   # Combine folder + criteria
```

**Tag Criteria:**
- Judgment rules: [`skills/tag-criteria/SKILL.md`](skills/tag-criteria/SKILL.md)
- Default tag definitions: [`skills/tag-criteria/tags/_all.md`](skills/tag-criteria/tags/_all.md)
- Custom criteria files can be placed in `tags/` directory and specified with `--criteria`

**Model Configuration:**

The auto-tagger agent uses `opus` model by default for highest accuracy. To change the model, edit `agents/obsidian-tagger.md`:

```yaml
model: opus  # Options: opus, sonnet, haiku
```

- `opus` - Default, highest accuracy (recommended)
- `sonnet` - Good balance of cost and accuracy (95% match with opus in testing)
- `haiku` - Fastest and cheapest, may reduce tagging accuracy

*More tools are planned for future releases.*

## Requirements

- Claude Code CLI
- Obsidian MCP Tools (obsidian-mcp-tools)
- Bash (Linux/macOS native, Windows via Git Bash)

## Installation

Run from Git Bash:

```bash
./deploy.sh
./deploy.sh --uninstall  # to uninstall
```

## Project Structure

```
obsidian-claude-tools/
├── .claude-plugin/
│   └── plugin.json           # Plugin metadata
├── agents/
│   └── obsidian-tagger.md    # Auto-tagger agent
├── commands/
│   └── tag-notes.md          # /tag-notes command
├── skills/
│   └── tag-criteria/
│       ├── SKILL.md          # Judgment rules
│       └── tags/
│           ├── _all.md       # Default tag definitions
│           └── *.md          # Custom criteria files
├── deploy.sh                 # Deployment script
└── README.md
```

## License

TBD
