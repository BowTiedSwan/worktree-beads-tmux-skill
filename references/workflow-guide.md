# Worktree-Beads-Tmux Workflow Guide

## Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [Installation & Setup](#installation--setup)
3. [Daily Workflow Patterns](#daily-workflow-patterns)
4. [Scenario-Based Guides](#scenario-based-guides)
5. [Troubleshooting](#troubleshooting)

---

## Architecture Overview

### The Four Pillars

```
┌─────────────────────────────────────────────────────────────────┐
│                    TMUX SESSION: "project"                      │
├──────────────────┬──────────────────┬───────────────────────────┤
│   Window 1:      │   Window 2:      │      Window 3:            │
│   Editor         │   Beads Viewer   │      Terminal             │
│                  │                  │                           │
│  ┌────────────┐  │  ┌────────────┐  │  ┌─────────────────────┐  │
│  │   Neovim   │  │  │     bv     │  │  │  git worktree list  │  │
│  │            │  │  │  (TUI)     │  │  │                     │  │
│  │  coding... │  │  │  Split:    │  │  │  ../feature-1       │  │
│  │            │  │  │  List +    │  │  │  ../hotfix          │  │
│  └────────────┘  │  │  Details   │  │  │  ../experiment      │  │
│                  │  └────────────┘  │  └─────────────────────┘  │
├──────────────────┴──────────────────┴───────────────────────────┤
│                    Window 4: Logs/Monitoring                    │
│  ┌─────────────────────────┬──────────────────────────────────┐│
│  │   App Server (main)     │   App Server (feature)           ││
│  │   localhost:3000        │   localhost:3001                 ││
│  └─────────────────────────┴──────────────────────────────────┘│
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                    GIT WORKTREES                                │
├─────────────────────────────────────────────────────────────────┤
│  ~/worktrees/myapp/          (main branch)                       │
│  ~/worktrees/myapp-feature/  (feature/new-auth branch)           │
│  ~/worktrees/myapp-hotfix/   (hotfix/login-bug branch)           │
├─────────────────────────────────────────────────────────────────┤
│  Each with:                                                     │
│  ├── .beads/ (beads task data - git-tracked)                   │
│  ├── .beads/beads.jsonl (task graph)                           │
│  └── node_modules/ (isolated per worktree)                     │
└─────────────────────────────────────────────────────────────────┘
```

### Why This Combination?

| Tool | Problem Solved | Key Benefit |
|------|---------------|-------------|
| **Git Worktrees** | Context switching overhead | Zero stash/checkout/pop - instant branch switching |
| **Beads** | Task management chaos | Dependency-aware graph structure, AI-optimized |
| **Beads Viewer** | Visibility into complexity | PageRank, critical path, cycle detection |
| **Tmux** | Session volatility | Persistent sessions survive disconnects |

---

## Installation & Setup

### System Prerequisites

```bash
# Check git version (need 2.5+)
git --version

# Check tmux
tmux -V

# Check shell (bash/zsh/fish supported)
echo $SHELL
```

### Step 1: Install Core Tools

```bash
# Install beads CLI
curl -fsSL https://raw.githubusercontent.com/steveyegge/beads/main/scripts/install.sh | bash

# Install beads viewer (macOS/Linux)
brew install dicklesworthstone/tap/bv

# Or use install script
curl -fsSL "https://raw.githubusercontent.com/Dicklesworthstone/beads_viewer/main/install.sh?$(date +%s)" | bash

# Install tmux
brew install tmux  # macOS
sudo apt-get install tmux  # Ubuntu/Debian
sudo yum install tmux  # RHEL/CentOS
```

### Step 2: Configure Shell Environment

Add to `~/.bashrc`, `~/.zshrc`, or `~/.config/fish/config.fish`:

```bash
# Beads
export PATH="$HOME/.beads/bin:$PATH"

# Tmux aliases
alias ta='tmux attach -t'
alias tn='tmux new-session -d -s'
alias tls='tmux ls'
alias tk='tmux kill-session -t'

# Worktree helpers
alias wl='git worktree list'
alias wp='git worktree prune'
```

### Step 3: Project Setup

```bash
# Create worktrees directory structure
mkdir -p ~/worktrees
cd ~/worktrees

# Clone repository as bare
git clone --bare git@github.com:yourusername/yourproject.git .git
cd .git

# Create main worktree
git worktree add ../main

# Navigate and initialize
cd ../main

# Initialize beads
bd init

# Create tmux session
tmux new-session -d -s yourproject -c ~/worktrees/main
tmux new-window -t yourproject:2 -n beads
tmux send-keys -t yourproject:2 "bv" Enter

# Create AGENTS.md
cat > AGENTS.md << 'EOF'
## Development Workflow

This project uses the worktree-beads-tmux workflow:

### Quick Commands
- `bd ready` - List tasks ready to work on
- `bv --robot-triage` - Get AI-friendly task analysis
- `git worktree list` - Show all worktrees
- `tmux attach -t yourproject` - Attach to project session

### Workflow Patterns
1. **Start work**: Check `bv --robot-triage` for top priorities
2. **Claim task**: `bd update <id> --claim`
3. **Context switch**: Use worktrees, never stash
4. **End day**: `bd sync` and detach tmux session

### Beads Robot Commands (for AI)
```bash
bv --robot-triage          # Full project analysis
bv --robot-next            # Top priority task only
bv --robot-plan            # Parallel execution tracks
bv --robot-insights        # Graph metrics & bottlenecks
```
EOF
```

---

## Daily Workflow Patterns

### Morning: Start of Day

```bash
# Attach to tmux session
tmux attach -t yourproject

# Switch to beads window (Ctrl+b 2)
# Review tasks in TUI

# Get AI analysis for planning
bv --robot-triage

# Claim top priority task
bd update bd-a1b2 --claim

# Switch to editor window and start coding
```

### Mid-Day: Context Switch

```bash
# Urgent hotfix comes in

# Option 1: If hotfix worktree exists
cd ~/worktrees/yourproject-hotfix
tmux attach -t yourproject-hotfix

# Option 2: Create new worktree
git worktree add ../hotfix-$(date +%s) main
cd ../hotfix-*
tmux new-session -d -s yourproject-hotfix
tmux attach -t yourproject-hotfix

# Fix the issue
git commit -am "Hotfix: description"
git push

# Return to feature work
cd ~/worktrees/yourproject-feature
tmux attach -t yourproject-feature
# Continue exactly where you left off - no stash pop needed!
```

### Evening: End of Day

```bash
# Sync beads data
bd sync

# Export daily report
bv --export-md ~/reports/$(date +%Y-%m-%d).md

# Check project health
bv --robot-insights | jq '.quick_ref'

# Detach tmux session (keeps running)
Ctrl+b d

# Or kill if done for the day
tmux kill-session -t yourproject
```

---

## Scenario-Based Guides

### Scenario 1: Long-Running Feature Development

**Context**: Starting a complex feature that will take 2-3 weeks

```bash
# Step 1: Create dedicated worktree
cd ~/worktrees/yourproject/.git
git worktree add ../feature-oauth -b feature/oauth-implementation
cd ../feature-oauth

# Step 2: Initialize beads
bd init

# Step 3: Break down the epic
bd create "Epic: OAuth Implementation" -p 0
EPIC_ID=$(bd list | grep "OAuth Implementation" | awk '{print $1}')

bd create "Setup OAuth provider configs" -p 1 --parent $EPIC_ID
bd create "Implement login endpoint" -p 1 --parent $EPIC_ID
bd create "Create token refresh logic" -p 1 --parent $EPIC_ID
bd create "Add middleware for protected routes" -p 1 --parent $EPIC_ID
bd create "Write OAuth tests" -p 2 --parent $EPIC_ID

# Step 4: Setup tmux session
tmux new-session -d -s yourproject-oauth -c ~/worktrees/feature-oauth
tmux new-window -t yourproject-oauth:2 -n beads
tmux new-window -t yourproject-oauth:3 -n tests
tmux send-keys -t yourproject-oauth:2 "bv" Enter

# Step 5: Daily workflow
# Each morning:
tmux attach -t yourproject-oauth
bv --robot-plan  # Get parallel execution tracks
bd update <id> --claim
# Code...
bd update <id> --status done
```

### Scenario 2: Code Review Multi-PR

**Context**: Need to review 3 different PRs

```bash
# Create worktrees for each PR
for PR in 123 124 125; do
  git worktree add --detach ../pr-$PR
  cd ../pr-$PR
  git fetch origin pull/$PR/head:pr-$PR
  git checkout pr-$PR
  tmux new-window -t yourproject: -n pr-$PR -c ~/worktrees/pr-$PR
done

# Review each in its own window
tmux attach -t yourproject
# Use Ctrl+b <window-number> to switch between PRs

# When done reviewing
for PR in 123 124 125; do
  rm -rf ~/worktrees/pr-$PR
done
git worktree prune
```

### Scenario 3: Experiment/Spike

**Context**: Want to try a risky refactoring approach

```bash
# Create isolated experiment worktree
git worktree add ../experiment-refactor -b experiment/refactor
cd ../experiment-refactor

# If it works out
cd ~/worktrees/yourproject/.git
git checkout main
git merge experiment/refactor

# If it doesn't work out
rm -rf ../experiment-refactor
git worktree prune
git branch -D experiment/refactor
# Zero impact on main worktree
```

### Scenario 4: Production Hotfix

**Context**: Production bug while in middle of feature work

```bash
# Traditional approach (BAD):
# git stash (messy state)
# git checkout main
# fix bug
# git checkout feature-branch
# git stash pop (hope no conflicts)

# Worktree approach (GOOD):
# You're in ~/worktrees/feature-branch, coding away

# Create hotfix worktree
git worktree add ../hotfix-production main
cd ../hotfix-production
tmux new-session -d -s yourproject-hotfix
tmux attach -t yourproject-hotfix

# Fix bug
vim fix.js
git commit -am "Fix production issue"
git push

# Deploy...

# Return to feature work
cd ~/worktrees/feature-branch
tmux attach -t yourproject-feature
# EXACTLY where you left off. No stash. No conflicts. No context loss.
```

---

## Troubleshooting

### Common Worktree Issues

**Issue**: "fatal: '<path>' is already checked out at '<other-path>'"

```bash
# Find where branch is checked out
git worktree list

# Either switch to that worktree or remove it
git worktree remove <path>
# OR
rm -rf <path> && git worktree prune
```

**Issue**: Worktree appears in list but directory was deleted

```bash
# Clean up stale references
git worktree prune -v

# If still showing, force remove
git worktree remove <path> --force
```

### Common Beads Issues

**Issue**: "bd: command not found"

```bash
# Check if in PATH
echo $PATH | grep beads

# Add to shell config
echo 'export PATH="$HOME/.beads/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc

# Or reinstall
curl -fsSL https://raw.githubusercontent.com/steveyegge/beads/main/scripts/install.sh | bash
```

**Issue**: "bv: command not found"

```bash
# macOS with Homebrew
brew install dicklesworthstone/tap/bv

# Or manual install
curl -fsSL "https://raw.githubusercontent.com/Dicklesworthstone/beads_viewer/main/install.sh?$(date +%s)" | bash
```

**Issue**: Beads viewer shows garbled characters

```bash
# Check terminal supports Unicode
echo -e '\u2500\u2502\u250c\u2510\u2514\u2518'

# Try ASCII mode
bv --ascii

# Or check terminal emulator
# Recommended: iTerm2, Windows Terminal, Alacritty
```

### Common Tmux Issues

**Issue**: "can't create socket"

```bash
# Check permissions
ls -la /tmp/tmux-*

# Fix ownership
sudo chown -R $USER /tmp/tmux-*

# Or set custom socket dir
export TMUX_TMPDIR=~/.tmux-sockets
mkdir -p $TMUX_TMPDIR
```

**Issue**: Lost connection, session gone

```bash
# List all sessions
tmux ls

# If not showing, check if tmux server running
pgrep tmux

# If server crashed, check logs
# Tmux doesn't keep logs by default, add to config:
# set -g history-file ~/.tmux_history
```

**Issue**: Key bindings not working

```bash
# Check current prefix
tmux show-options -g prefix

# Check if keys bound
tmux list-keys | grep -A2 <key>

# Send prefix literally if needed
Ctrl+b Ctrl+b  # Sends Ctrl+b to application
```

---

## Advanced Tips

### Bare Repository Pattern

Keep your home directory clean with bare repos:

```
~/worktrees/
└── myproject/
    ├── .git/              # Bare repository (all branches)
    ├── main/              # worktree for main
    ├── develop/           # worktree for develop
    ├── feature-*/         # worktrees for features
    └── hotfix-*/          # worktrees for hotfixes
```

### Tmux Configuration

Create `~/.tmux.conf`:

```bash
# Change prefix to Ctrl+a (easier to reach)
unbind C-b
set-option -g prefix C-a
bind-key C-a send-prefix

# Mouse support
set -g mouse on

# Vi mode
setw -g mode-keys vi

# Start windows at 1
set -g base-index 1
setw -g pane-base-index 1

# Auto-rename windows
setw -g automatic-rename on
set -g renumber-windows on

# Status bar
set -g status-bg colour235
set -g status-fg colour250
set -g status-left '#[fg=green]#S #[default]'
set -g status-right '#[fg=yellow]%H:%M #[default]'

# Increase history
set -g history-limit 10000

# Pane borders
set -g pane-border-style fg=colour238
set -g pane-active-border-style fg=colour250
```

### Shell Functions

Add to your shell:

```bash
# Quick worktree switch
wt() {
  local worktree=$1
  if [ -z "$worktree" ]; then
    git worktree list
  else
    cd ~/worktrees/$worktree 2>/dev/null || cd $worktree
  fi
}

# Create worktree with tmux session
wtn() {
  local name=$1
  local branch=${2:-main}
  
  git worktree add ../$name $branch
  cd ../$name
  
  tmux new-session -d -s $(basename $PWD)-$name
  tmux new-window -t $(basename $PWD)-$name:2 -n beads
  tmux send-keys -t $(basename $PWD)-$name:2 "bv" Enter
  
  echo "Created worktree $name with tmux session"
  echo "Attach with: tmux attach -t $(basename $PWD)-$name"
}

# Switch to worktree with tmux
twa() {
  local name=$1
  local project=$(basename $(git rev-parse --show-toplevel))
  tmux attach -t ${project}-${name}
}
```

---

## Further Reading

- **Beads Documentation**: https://github.com/steveyegge/beads
- **Beads Viewer**: https://github.com/Dicklesworthstone/beads_viewer
- **Git Worktrees**: https://git-scm.com/docs/git-worktree
- **Tmux Wiki**: https://github.com/tmux/tmux/wiki
- **Tmux Cheat Sheet**: https://tmuxcheatsheet.com/
