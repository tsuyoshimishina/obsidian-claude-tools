#!/usr/bin/env bash
# deploy.sh - Obsidian Claude Tools Deployment Script
# Deploys plugin files to ~/.claude/

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
PLUGIN_NAME="obsidian-auto-tagger"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_BASE="$HOME/.claude"

# Target paths
SKILLS_TARGET="$TARGET_BASE/skills"
AGENTS_TARGET="$TARGET_BASE/agents"
COMMANDS_TARGET="$TARGET_BASE/commands"

write_status() {
    local message="$1"
    local type="${2:-Info}"
    case "$type" in
        Success) echo -e "${GREEN}[Success]${NC} $message" ;;
        Warning) echo -e "${YELLOW}[Warning]${NC} $message" ;;
        Error)   echo -e "${RED}[Error]${NC} $message" ;;
        *)       echo -e "${CYAN}[Info]${NC} $message" ;;
    esac
}

install_plugin() {
    write_status "Installing $PLUGIN_NAME..." "Info"

    # Copy skills (folder)
    local skills_source="$SCRIPT_DIR/skills/tag-criteria"
    local skills_target="$SKILLS_TARGET/tag-criteria"
    if [ -d "$skills_source" ]; then
        mkdir -p "$skills_target"
        cp -r "$skills_source"/* "$skills_target/"
        write_status "Copied skills to: $skills_target" "Success"
    else
        write_status "Skills source not found: $skills_source" "Warning"
    fi

    # Copy agents
    local agents_source="$SCRIPT_DIR/agents"
    if [ -d "$agents_source" ]; then
        mkdir -p "$AGENTS_TARGET"
        cp "$agents_source"/*.md "$AGENTS_TARGET/"
        write_status "Copied agents to: $AGENTS_TARGET" "Success"
    else
        write_status "Agents source not found: $agents_source" "Warning"
    fi

    # Copy commands
    local commands_source="$SCRIPT_DIR/commands"
    if [ -d "$commands_source" ]; then
        mkdir -p "$COMMANDS_TARGET"
        cp "$commands_source"/*.md "$COMMANDS_TARGET/"
        write_status "Copied commands to: $COMMANDS_TARGET" "Success"
    else
        write_status "Commands source not found: $commands_source" "Warning"
    fi

    echo ""
    write_status "Installation complete!" "Success"
    write_status "Restart Claude Code to load the plugin." "Info"
    echo ""
    echo "Deployed files:"
    echo "  - $skills_target/SKILL.md"
    echo "  - $skills_target/tags/*.md"
    echo "  - $AGENTS_TARGET/obsidian-tagger.md"
    echo "  - $COMMANDS_TARGET/tag-notes.md"
}

uninstall_plugin() {
    write_status "Uninstalling $PLUGIN_NAME..." "Warning"

    # Remove skill
    local skill_dir="$SKILLS_TARGET/tag-criteria"
    if [ -d "$skill_dir" ]; then
        rm -rf "$skill_dir"
        write_status "Removed skill: tag-criteria" "Success"
    else
        write_status "Skill not found: $skill_dir" "Warning"
    fi

    # Remove agent
    local agent_file="$AGENTS_TARGET/obsidian-tagger.md"
    if [ -f "$agent_file" ]; then
        rm -f "$agent_file"
        write_status "Removed agent: obsidian-tagger.md" "Success"
    else
        write_status "Agent not found: $agent_file" "Warning"
    fi

    # Remove command
    local command_file="$COMMANDS_TARGET/tag-notes.md"
    if [ -f "$command_file" ]; then
        rm -f "$command_file"
        write_status "Removed command: tag-notes.md" "Success"
    else
        write_status "Command not found: $command_file" "Warning"
    fi

    echo ""
    write_status "Uninstallation complete!" "Success"
}

# Main execution
echo ""
echo -e "${CYAN}========================================${NC}"
echo -e "${CYAN}  Obsidian Claude Tools Deploy Script${NC}"
echo -e "${CYAN}========================================${NC}"
echo ""

case "${1:-}" in
    --uninstall|-u)
        uninstall_plugin
        ;;
    --help|-h)
        echo "Usage: $0 [OPTIONS]"
        echo ""
        echo "Options:"
        echo "  --uninstall, -u    Uninstall the plugin"
        echo "  --help, -h         Show this help message"
        echo ""
        ;;
    *)
        install_plugin
        ;;
esac
