#!/bin/bash
#
# Quick context switcher for worktree-beads-tmux workflow
# Usage: ./switch-context.sh [project-name] [worktree-name]
#

set -e

PROJECT_NAME=$1
WORKTREE_NAME=$2

# If no args, show available projects
if [ -z "$PROJECT_NAME" ]; then
  echo "📁 Available projects in ~/worktrees/:"
  for dir in ~/worktrees/*/; do
    if [ -d "$dir" ]; then
      project=$(basename "$dir")
      echo "  - $project"
    fi
  done
  echo ""
  echo "Usage: $0 <project-name> [worktree-name]"
  exit 0
fi

PROJECT_DIR=~/worktrees/${PROJECT_NAME}

if [ ! -d "$PROJECT_DIR" ]; then
  echo "❌ Project '$PROJECT_NAME' not found in ~/worktrees/"
  exit 1
fi

# If no worktree specified, show available worktrees
if [ -z "$WORKTREE_NAME" ]; then
  echo "🌳 Available worktrees for $PROJECT_NAME:"
  cd ${PROJECT_DIR}/.git 2>/dev/null || cd ${PROJECT_DIR}
  if [ -d ".git" ]; then
    git worktree list
  else
    for dir in ${PROJECT_DIR}/*/; do
      if [ -d "$dir" ]; then
        echo "  - $(basename "$dir")"
      fi
    done
  fi
  echo ""
  echo "Usage: $0 $PROJECT_NAME <worktree-name>"
  exit 0
fi

WORKTREE_DIR=${PROJECT_DIR}/${WORKTREE_NAME}

if [ ! -d "$WORKTREE_DIR" ]; then
  echo "❌ Worktree '$WORKTREE_NAME' not found"
  echo "Available worktrees:"
  ls -1 ${PROJECT_DIR}/
  exit 1
fi

# Check for tmux session
SESSION_NAME="${PROJECT_NAME}-${WORKTREE_NAME}"

if command -v tmux &> /dev/null; then
  if tmux has-session -t ${SESSION_NAME} 2>/dev/null; then
    echo "🔗 Attaching to existing tmux session: $SESSION_NAME"
    tmux attach -t ${SESSION_NAME}
  else
    echo "🆕 Creating new tmux session: $SESSION_NAME"
    cd ${WORKTREE_DIR}
    tmux new-session -d -s ${SESSION_NAME} -c ${WORKTREE_DIR}
    tmux new-window -t ${SESSION_NAME}:2 -n beads
    
    if command -v bv &> /dev/null && [ -f "${WORKTREE_DIR}/.beads/beads.jsonl" ]; then
      tmux send-keys -t ${SESSION_NAME}:2 "bv" Enter
    fi
    
    tmux attach -t ${SESSION_NAME}
  fi
else
  echo "⚠️  tmux not installed, switching directory only"
  cd ${WORKTREE_DIR}
  exec $SHELL
fi
