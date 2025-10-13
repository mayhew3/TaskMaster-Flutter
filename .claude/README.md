# .claude Directory

This directory contains documentation and guidance for Claude Code when working with this repository.

## 📋 Quick Reference

**Starting migration?** → Read files in this order:
1. **TESTING_PLAN.md** ⚠️ MUST DO FIRST
2. **MIGRATION_PLAN.md** (after tests complete)
3. **QUICK_START.md** (implementation guide)
4. **PATTERNS.md** (reference while coding)

## Files

### TESTING_PLAN.md ⚠️ START HERE
**Priority:** CRITICAL - Do this first before any migration work.

Pre-migration testing strategy with detailed test requirements, implementation guide, and code examples. Identifies critical testing gaps and provides step-by-step instructions for writing integration tests and screen tests.

**Required before migration:**
- 5+ critical path integration tests
- 15+ screen widget tests
- >70% code coverage

**Start here if:** You're about to begin migration (everyone should read this first).

### MIGRATION_PLAN.md
Complete Redux → Riverpod migration strategy with phase-by-phase instructions, code examples, and testing guidelines. This is the primary reference document for the architectural modernization effort.

**Start here if:** Testing phase is complete and you're ready to implement the migration.

### QUICK_START.md
Step-by-step guide to complete Phase 0 (foundation setup) in ~30 minutes. Includes all commands, code snippets, and verification steps.

**Start here if:** You want to quickly set up Riverpod infrastructure (after testing complete).

### PATTERNS.md
Common Riverpod patterns, best practices, and code examples specific to TaskMaster. Includes provider types, testing patterns, and Redux → Riverpod conversion examples.

**Start here if:** You're writing new Riverpod code or converting existing Redux code.

### METRICS.md
Template for tracking migration progress and performance improvements. Includes baseline metrics, checkpoints, and success criteria.

**Start here if:** You need to measure progress or document improvements.

### QUESTIONS.md
Common questions about migration with answers. Covers topics like model migration strategy, offline support, navigation, testing, and coexistence of Redux/Riverpod.

**Start here if:** You have specific questions about the migration approach.

## Usage

These files are referenced by `CLAUDE.md` in the project root and are automatically available to Claude Code instances working in this repository.

## Contributing

Feel free to update these documents as you learn new patterns or encounter edge cases during the migration. Keep them concise and code-focused.
