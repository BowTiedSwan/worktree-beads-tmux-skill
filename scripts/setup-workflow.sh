#!/bin/bash
#
# Setup script for worktree-beads-tmux workflow
# Usage: ./setup-workflow.sh <project-name> <repo-url>
#

set -e

PROJECT_NAME=$1
REPO_URL=$2

if [ -z "$PROJECT_NAME" ] || [ -z "$REPO_URL" ]; then
  echo "Usage: $0 <project-name> <repo-url>"
  echo "Example: $0 myapp git@github.com:user/myapp.git"
  exit 1
fi

echo "🚀 Setting up worktree-beads-tmux workflow for: $PROJECT_NAME"

# Create directory structure
mkdir -p ~/worktrees/${PROJECT_NAME}
cd ~/worktrees/${PROJECT_NAME}

echo "📦 Cloning repository as bare..."
git clone --bare ${REPO_URL} .git
cd .git

echo "🌳 Creating main worktree..."
git worktree add ../main

# Initialize beads
cd ../main
echo "📋 Initializing beads..."
if command -v bd &> /dev/null; then
  bd init
  echo "✅ Beads initialized"
else
  echo "⚠️  beads not installed. Install from: https://github.com/steveyegge/beads"
fi

# Create AGENTS.md if it doesn't exist
if [ ! -f "AGENTS.md" ]; then
  echo "📝 Creating AGENTS.md..."
  cat > AGENTS.md << 'EOF'
## Development Workflow

This project uses the worktree-beads-tmux workflow for optimized development.

### Quick Commands
- `bd ready` - List tasks ready to work on
- `bv --robot-triage` - Get AI-friendly task analysis
- `git worktree list` - Show all worktrees
- `tmux attach -t PROJECT_NAME` - Attach to project session

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

### Worktrees
- Main: ~/worktrees/PROJECT_NAME/main
- Create new: `git worktree add ../feature-name -b feature/name`
- List: `git worktree list`
- Remove: `rm -rf ../feature-name && git worktree prune`

### Tmux Sessions
- Attach: `tmux attach -t PROJECT_NAME`
- Detach: Ctrl+b d
- Windows: Ctrl+b <number>
EOF
  # Replace PROJECT_NAME placeholder
  sed -i.bak "s/PROJECT_NAME/${PROJECT_NAME}/g" AGENTS.md
  rm AGENTS.md.bak
fi

# Setup tmux session
echo "🖥️  Setting up tmux session..."
if command -v tmux &> /dev/null; then
  if ! tmux has-session -t ${PROJECT_NAME} 2>/dev/null; then
    tmux new-session -d -s ${PROJECT_NAME} -c ~/worktrees/${PROJECT_NAME}/main
    tmux new-window -t ${PROJECT_NAME}:2 -n beads
    
    # Start beads viewer if available
    if command -v bv &> /dev/null; then
      tmux send-keys -t ${PROJECT_NAME}:2 "cd ~/worktrees/${PROJECT_NAME}/main && bv" Enter
    else
      tmux send-keys -t ${PROJECT_NAME}:2 "cd ~/worktrees/${PROJECT_NAME}/main" Enter
    fi
    
    tmux new-window -t ${PROJECT_NAME}:3 -n terminal
    echo "✅ Tmux session '${PROJECT_NAME}' created"
  else
    echo "ℹ️  Tmux session '${PROJECT_NAME}' already exists"
  fi
else
  echo "⚠️  tmux not installed. Install with: brew install tmux (macOS) or apt-get install tmux (Linux)"
fi

echo ""
echo "✅ Setup complete for: $PROJECT_NAME"
echo ""
echo "📁 Project location: ~/worktrees/${PROJECT_NAME}/main"
echo "🔗 Attach to tmux:   tmux attach -t ${PROJECT_NAME}"
echo "📋 View worktrees:   git worktree list"
echo ""
echo "🚀 Get started:"
echo "   cd ~/worktrees/${PROJECT_NAME}/main"
echo "   tmux attach -t ${PROJECT_NAME}"
echo ""
