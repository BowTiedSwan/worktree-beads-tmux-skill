# Worktree-Beads-Tmux Orchestrator

[![Skill](https://img.shields.io/badge/Claude%20Code-Skill-blue)](https://github.com/steveyegge/beads)
[![Beads](https://img.shields.io/badge/Beads-Task%20Tracker-green)](https://github.com/steveyegge/beads)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

A Claude Code skill that orchestrates a professional-grade development workflow by combining **Git Worktrees**, **Beads task management**, and **Tmux session management**.

## 🎯 What This Skill Does

This skill automatically detects your development scenario and provides optimized workflow patterns:

- **Long-Running Features**: Isolated worktrees with dedicated tmux sessions
- **Hotfix Interrupts**: Instant context switching without stash/checkout/pop
- **Multi-Branch Reviews**: Parallel PR review environments
- **Task Management**: Beads integration for dependency-aware planning
- **Terminal Organization**: Persistent sessions that survive disconnects

## 📦 Installation

### 1. Install Prerequisites

```bash
# Install beads CLI
curl -fsSL https://raw.githubusercontent.com/steveyegge/beads/main/scripts/install.sh | bash

# Install beads viewer (bv)
brew install dicklesworthstone/tap/bv

# Install tmux
brew install tmux  # macOS
sudo apt-get install tmux  # Ubuntu/Debian
```

### 2. Install This Skill

**Option A: Direct Download**
```bash
# Download the skill
curl -L https://github.com/bowtiedswan/worktree-beads-tmux-skill/archive/refs/heads/main.zip -o skill.zip
unzip skill.zip

# Copy to Claude skills directory
cp -r worktree-beads-tmux-skill ~/.claude/skills/
```

**Option B: Git Clone**
```bash
cd ~/.claude/skills
git clone https://github.com/bowtiedswan/worktree-beads-tmux-skill.git
```

### 3. Verify Installation

```bash
# Check skill is available
ls ~/.claude/skills/worktree-beads-tmux-skill/

# Should show:
# SKILL.md  references/  scripts/
```

## 🚀 Quick Start

### Setup a New Project

```bash
# Use the setup script
./scripts/setup-workflow.sh myproject git@github.com:user/myproject.git

# This creates:
# ~/worktrees/myproject/
# ├── .git/              # Bare repository
# ├── main/              # Main worktree with beads initialized
# └── tmux session: myproject (with editor, beads viewer, terminal windows)
```

### Daily Workflow

```bash
# Attach to your project
tmux attach -t myproject

# In the beads window (Ctrl+b 2), view tasks
# Or get AI-friendly analysis:
bv --robot-triage

# Claim a task and start working
bd update bd-a1b2 --claim

# When interrupted, create hotfix worktree
git worktree add ../hotfix main
cd ../hotfix
# Fix, commit, push, return to main worktree - zero context loss!
```

## 📚 Documentation

- **[Workflow Guide](references/workflow-guide.md)** - Comprehensive workflow documentation
- **[SKILL.md](SKILL.md)** - Skill reference and commands

## 🔧 Included Scripts

### setup-workflow.sh
One-command project setup:
```bash
./scripts/setup-workflow.sh <project-name> <repo-url>
```

### switch-context.sh
Quick context switcher:
```bash
./scripts/switch-context.sh [project-name] [worktree-name]
```

### standup-report.sh
Generate daily standup reports:
```bash
./scripts/standup-report.sh [project-path]
```

## 🎭 Trigger Scenarios

This skill activates when you mention:

- "Setup worktree workflow"
- "Manage multiple branches"
- "Parallel development"
- "Beads task tracking"
- "Tmux session for project"
- "Context switching"
- "Hotfix while coding"
- "Organize development environment"

## 🏗️ Architecture

```
┌──────────────────────────────────────────────────────────────┐
│                      TMUX SESSION                            │
├──────────────┬──────────────┬──────────────┬─────────────────┤
│  Window 1    │  Window 2    │  Window 3    │   Window 4      │
│  Editor      │  Beads (bv)  │  Terminal    │   Logs          │
├──────────────┴──────────────┴──────────────┴─────────────────┤
│                    GIT WORKTREES                              │
├──────────────────────────────────────────────────────────────┤
│  ~/worktrees/project/main        (main branch)               │
│  ~/worktrees/project/feature-x   (feature branch)            │
│  ~/worktrees/project/hotfix      (hotfix branch)             │
├──────────────────────────────────────────────────────────────┤
│  Each worktree has:                                          │
│  ├── .beads/beads.jsonl  (dependency graph)                  │
│  └── Isolated dependencies (node_modules, venv, etc.)        │
└──────────────────────────────────────────────────────────────┘
```

## 📖 Common Patterns

### Pattern 1: Long-Running Feature
```bash
git worktree add ../feature-oauth -b feature/oauth
bd init  # In new worktree
tmux new-session -d -s project-oauth
bv --robot-plan  # Get parallel execution tracks
```

### Pattern 2: Hotfix Interrupt
```bash
# From your feature work, no stash needed:
git worktree add ../hotfix main
cd ../hotfix
# Fix and push
cd ../feature  # Back to exactly where you were
```

### Pattern 3: PR Review
```bash
./scripts/switch-context.sh myproject pr-123
# Review in isolated environment
# Delete when done: rm -rf ../pr-123 && git worktree prune
```

## 🛠️ Troubleshooting

### Beads not found
```bash
export PATH="$HOME/.beads/bin:$PATH"
```

### Worktree already exists
```bash
git worktree prune -v
# Or force remove: git worktree remove <path> --force
```

### Tmux session conflicts
```bash
tmux ls                    # List sessions
tmux kill-session -t name  # Kill specific session
```

## 🔗 Resources

- [Beads Documentation](https://github.com/steveyegge/beads)
- [Beads Viewer](https://github.com/Dicklesworthstone/beads_viewer)
- [Git Worktrees](https://git-scm.com/docs/git-worktree)
- [Tmux Wiki](https://github.com/tmux/tmux/wiki)

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Acknowledgments

- [Steve Yegge](https://github.com/steveyegge) for creating Beads
- [Dicklesworthstone](https://github.com/Dicklesworthstone) for Beads Viewer
- The Git and Tmux communities for their excellent tools

---

**Happy coding with zero context loss!** 🚀
