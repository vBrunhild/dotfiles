---
name: eza
description: a modern alternative for `ls`.
---

# eza — Modern File Listing

## When to Use

Use `eza` as a drop-in replacement for `ls` whenever you need to list, inspect, or explore files and directories in a detailed manner. It adds color-coded output, git status integration, tree views, and human-readable defaults out of the box. Prefer `eza` over `ls` for any interactive or scripted file listing where readability matters.

**Trigger on:** listing directory contents, visualizing file trees, checking file metadata (size, permissions, timestamps, git status), or exploring project structures.

**Don't use when:** you need POSIX-strict `ls` output for portable shell scripts, or the environment doesn't have `eza` installed.

---

## Core Syntax

```
eza [OPTIONS] [PATH...]
```

If no path is given, `eza` lists the current directory. Multiple paths can be listed at once.

### Key Options

| Flag | Purpose |
|---|---|
| `-l` | Long format (permissions, size, date, owner) |
| `-a` | Show all files including hidden (dotfiles) |
| `-A` | Show hidden files, but exclude `.` and `..` |
| `-1` | One entry per line |
| `-T` | Tree view (recursive) |
| `-L N` | Limit tree/recursion depth to N levels |
| `-R` | Recurse into directories (flat, non-tree) |
| `-d` | List directories themselves, not their contents |
| `-D` | List only directories |
| `-f` | List only files |
| `-r` | Reverse sort order |
| `-s FIELD` | Sort by field (see Sorting section) |
| `--group-directories-first` | Directories before files |
| `--git` | Show git status for each file |
| `--git-repos` | Show git repo status in directory listings |
| `--icons` | Show file-type icons (requires Nerd Font) |
| `--no-permissions` | Hide permissions column in long view |
| `--no-user` | Hide owner column in long view |
| `--no-time` | Hide timestamp column in long view |
| `--total-size` | Show directory total sizes (recursive calc) |
| `--color=WHEN` | `always`, `auto`, `never` |

---

## Essential Patterns

### 1. Basic Listing

```bash
# Simple listing (colored, multi-column)
eza

# Long format
eza -l

# Show hidden files
eza -a

# Long format with hidden files
eza -la

# One file per line
eza -1

# List specific directory
eza -l /etc/nginx/

# List multiple paths
eza -l src/ tests/ docs/
```

### 2. Tree View

```bash
# Full recursive tree
eza -T

# Tree limited to 2 levels deep
eza -T -L 2

# Tree with file metadata
eza -Tl -L 3

# Tree with git status
eza -T --git

# Tree ignoring node_modules and .git
eza -T -I 'node_modules|.git'

# Tree of only directories
eza -TD -L 2
```

### 3. Sorting

```bash
# Sort by size (largest last)
eza -l -s size

# Sort by size, largest first
eza -l -s size -r

# Sort by modification time (oldest first)
eza -l -s modified

# Most recently modified first
eza -l -s modified -r

# Sort by file extension
eza -l -s ext

# Sort by name (default, case-insensitive)
eza -l -s name

# Directories first, then sorted by name
eza -l --group-directories-first
```

Available sort fields: `name`, `Name` (case-sensitive), `size`, `ext` (extension), `modified`, `accessed`, `created`, `inode`, `type`, `none`.

### 4. Filtering

```bash
# Only directories
eza -D

# Only files (no directories)
eza -f

# Ignore patterns (glob-based)
eza -I '*.pyc|__pycache__|.git'

# Only show specific glob (combine with find or shell globs)
eza -l *.json

# List directories themselves (not their contents)
eza -ld src/ tests/ docs/

# Show only dotfiles
eza -a -I '[^.]*'
```

### 5. Git Integration

```bash
# Show per-file git status in long view
eza -l --git

# Git status indicators:
#   N  = new (untracked)
#   M  = modified
#   -  = unmodified
#   I  = ignored

# Show repo-level status for directories
eza -l --git-repos

# Tree with git status
eza -T --git -L 2

# Combine with directories-first for project overview
eza -l --git --group-directories-first
```

### 6. Columns & Metadata

```bash
# Full detail (permissions, owner, group, size, date)
eza -l

# Long format with header labels
eza -lh

# Add inode numbers
eza -l --inode

# Add number of hard links
eza -l --links

# Show file sizes in binary (KiB, MiB) instead of decimal (KB, MB)
eza -l --binary

# Show total size of directories (expensive on large trees)
eza -l --total-size

# Minimal long view (just size and name)
eza -l --no-permissions --no-user --no-time

# Show extended attributes and file flags
eza -l@
```

### 7. Time & Date

```bash
# Show modification time (default in long view)
eza -l

# Show creation time
eza -l --time=created

# Show access time
eza -l --time=accessed

# Custom time style
eza -l --time-style=long-iso

# Relative timestamps ("2 hours ago")
eza -l --time-style=relative

# Sort by creation time, newest first
eza -l -s created -r
```

### 8. Display & Output

```bash
# Enable icons (needs Nerd Font in terminal)
eza --icons

# Long + icons + git (the "everything" view)
eza -l --icons --git

# Grid view (default, multi-column)
eza -G

# Across (fill rows before columns)
eza -x

# Force plain output for piping
eza --color=never -1

# Hyperlink filenames (clickable in supported terminals)
eza -l --hyperlink
```

---

## Common Recipes

```bash
# Project overview: tree + git + icons, 3 levels
eza -T -L 3 --git --icons --group-directories-first

# Find the largest files in current directory
eza -l -s size -r | head -20

# Quick directory size audit
eza -l --total-size -s size -r -D

# List only recently modified files (combine with sort)
eza -l -s modified -r | head -10

# Compare two directories at a glance
eza -1 dir_a/ > /tmp/a.txt && eza -1 dir_b/ > /tmp/b.txt && diff /tmp/a.txt /tmp/b.txt

# Dotfile audit (see all hidden config files)
eza -la --no-permissions --no-user -I '[^.]*'

# Repo root overview with git status
eza -l --git --git-repos --group-directories-first -D

# Exportable file list (one per line, no color)
eza -1 --color=never -a > filelist.txt

# Count files by extension
eza -1 -r -R | grep -o '\.[^.]*$' | sort | uniq -c | sort -rn

# Scripting-safe: list only filenames with no decoration
eza -1 --color=never --no-icons
```

---

## Gotchas

- **Not POSIX-compatible:** output format differs from `ls`. Don't use in scripts that parse `ls` output for portability.
- **Icons require a Nerd Font:** `--icons` shows broken glyphs without one installed and active in your terminal.
- **`--total-size` is slow:** it recursively calculates directory sizes. Avoid on large filesystems.
- **Git status adds latency:** `--git` runs git-status per file. In very large repos this can be noticeable; `--git-repos` at the directory level is lighter.
- **No built-in glob filter:** unlike `ls`, there's no `--glob` flag. Use `-I` for exclusions, or rely on shell globbing for inclusions.
- **Color in pipes:** color is auto-disabled when piping. Use `--color=always` if downstream tools expect ANSI codes (e.g., `less -R`).
- **Sorting is ascending by default:** newest/largest last. Add `-r` to reverse for "top N" use cases.
