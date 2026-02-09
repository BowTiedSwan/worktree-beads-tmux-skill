#!/bin/bash
#
# Daily standup report generator for beads projects
# Usage: ./standup-report.sh [project-path]
#

set -e

PROJECT_PATH=${1:-.}
cd ${PROJECT_PATH}

echo "═══════════════════════════════════════════════════════════"
echo "📊 Daily Standup Report - $(date '+%Y-%m-%d %H:%M')"
echo "📁 Project: $(basename $(pwd))"
echo "═══════════════════════════════════════════════════════════"
echo ""

# Check if beads is initialized
if [ ! -f ".beads/beads.jsonl" ]; then
  echo "⚠️  No beads data found. Run 'bd init' first."
  exit 1
fi

# Check if bv is available
if ! command -v bv &> /dev/null; then
  echo "⚠️  beads viewer (bv) not installed"
  exit 1
fi

echo "🎯 Quick Overview:"
echo "─────────────────────────────────────────────────────────────"
bv --robot-triage | jq -r '.quick_ref' 2>/dev/null || echo "  (install jq for formatted output)"
echo ""

echo "📋 Top 5 Recommendations:"
echo "─────────────────────────────────────────────────────────────"
bv --robot-triage | jq -r '.recommendations[0:5] | .[] | "  • \(.id): \(.title) [\(.reason)]"' 2>/dev/null || bv --robot-triage
echo ""

echo "🚨 Blockers to Clear:"
echo "─────────────────────────────────────────────────────────────"
bv --robot-triage | jq -r '.blockers_to_clear | .[] | "  • \(.id) unblocks: \(.unblocks | join(", "))"' 2>/dev/null || echo "  (no blockers found or jq not installed)"
echo ""

echo "⚠️  Critical Path:"
echo "─────────────────────────────────────────────────────────────"
bv --robot-insights | jq -r '.CriticalPath.nodes | .[] | "  • \(.id) (\(.description // "no description"))"' 2>/dev/null || echo "  (critical path analysis requires jq)"
echo ""

echo "♻️  Cycles (if any):"
echo "─────────────────────────────────────────────────────────────"
CYCLES=$(bv --robot-insights | jq -r '.Cycles | length' 2>/dev/null || echo "0")
if [ "$CYCLES" != "0" ]; then
  echo "  ⚠️  Found $CYCLES cycles - these need to be resolved!"
  bv --robot-insights | jq -r '.Cycles | .[] | "  • Cycle: \(. | join(" -> "))"' 2>/dev/null
else
  echo "  ✅ No cycles detected"
fi
echo ""

echo "📝 Recent Changes (last 24h):"
echo "─────────────────────────────────────────────────────────────"
bv --robot-diff --diff-since "$(date -v-1d +%Y-%m-%d 2>/dev/null || date -d 'yesterday' +%Y-%m-%d)" 2>/dev/null | jq -r '
  .new_issues | .[] | "  + \(.id): \(.title)"
' || echo "  (diff analysis requires jq or may not be available)"
echo ""

echo "═══════════════════════════════════════════════════════════"
echo "💡 Next: Run 'bv --robot-triage' for full details"
echo "═══════════════════════════════════════════════════════════"
