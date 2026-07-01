---
name: ripgrep
description: ripgrep recursively searches directories for a regex pattern while respecting gitignore
---

# ripgrep (rg) — Fast Recursive Search

## When to Use

Use `rg` whenever you need to search for text patterns across files or directories. It's a faster, more ergonomic replacement for `grep -r` with sane defaults: respects `.gitignore`, skips binary files, and uses Rust-powered regex. Prefer `rg` over `grep` for any recursive or multi-file search.

**Trigger on:** finding strings or patterns in codebases, filtering log files, locating function/variable definitions, searching across file types, counting matches, or extracting structured matches from text.

**Don't use when:** you need in-place editing (`sed`/`awk`), JSON-aware filtering (`jq`).

---

## Core Syntax

```
rg [OPTIONS] PATTERN [PATH...]
```

If no path is given, `rg` searches the current directory recursively. Patterns are Rust-flavored regex by default.

### Key Options

| Flag | Purpose |
|---|---|
| `-i` | Case-insensitive search |
| `-s` | Case-sensitive (override smart-case) |
| `-S` | Smart-case: insensitive unless pattern has uppercase |
| `-w` | Match whole words only |
| `-x` | Match entire lines only |
| `-F` | Treat pattern as a fixed/literal string (no regex) |
| `-v` | Invert match (show non-matching lines) |
| `-c` | Count matches per file |
| `-l` | List only filenames with matches |
| `-L` | List only filenames without matches |
| `-n` | Show line numbers (default in terminal) |
| `-N` | Suppress line numbers |
| `-o` | Print only the matched portion, not the full line |
| `-r REPLACEMENT` | Replace matches in output (doesn't modify files) |
| `-m N` | Stop after N matches per file |
| `--json` | Output results as JSON (one object per line) |

---

## Essential Patterns

### 1. Basic Search

```bash
# Search recursively from current directory
rg 'TODO'

# Search a specific file or directory
rg 'error' /var/log/app.log
rg 'def ' src/

# Literal string (disable regex)
rg -F 'price >= 100' .

# Case-insensitive
rg -i 'config'

# Whole-word match (won't match "reconfigure")
rg -w 'config'
```

### 2. Regex

```bash
# Standard regex
rg 'fn\s+\w+\(' src/

# Capture groups with replacement (output only, no file change)
rg -o 'version:\s*"([^"]+)"' -r '$1' Cargo.toml

# Alternation
rg 'ERROR|WARN|FATAL' logs/

# Multiline matching (-U enables matching across line boundaries)
rg -U 'struct \w+\s*\{[^}]*\}' src/
```

### 3. File Type Filtering

```bash
# Only search Python files
rg 'import' -t py

# Only search JS and TS files
rg 'fetch(' -t js -t ts

# Exclude a file type
rg 'TODO' -T html

# List all known type aliases
rg --type-list

# Custom type definition (ad-hoc)
rg --type-add 'config:*.{yaml,yml,toml,ini}' -t config 'database'
```

### 4. File & Directory Filtering

```bash
# Only files matching a glob
rg 'main' -g '*.rs'

# Exclude a glob pattern
rg 'main' -g '!*.test.*'

# Multiple globs (include + exclude)
rg 'handler' -g '*.go' -g '!vendor/'

# Search hidden files (dotfiles) too
rg --hidden 'SECRET_KEY'

# Search files ignored by .gitignore
rg --no-ignore 'debug'

# Both hidden and ignored
rg -uu 'password'

# Include binary files as well (triple unrestricted)
rg -uuu 'magic_bytes'

# Specific filename pattern
rg 'listen' -g 'Dockerfile*'
```

### 5. Context Lines

```bash
# 3 lines after each match
rg -A 3 'panic!'

# 3 lines before each match
rg -B 3 'panic!'

# 3 lines before and after (combined context)
rg -C 3 'panic!'

# Useful for log analysis
rg -B 5 'FATAL' /var/log/app.log
```

### 6. Output Control

```bash
# Filenames only
rg -l 'deprecated'

# Files that DON'T match
rg -L 'copyright' --type py

# Count matches per file
rg -c 'TODO' src/

# Total count across all files
rg -c 'TODO' src/ | awk -F: '{s+=$2} END{print s}'

# Only the matched text (not full lines)
rg -o '\b[A-Z_]{3,}\b' src/

# Replace in output (preview what a substitution would look like)
rg 'http://' -r 'https://' config/

# No filename prefix (useful when piping)
rg --no-filename 'export' src/

# Null-separated filenames (safe for xargs)
rg -l -0 'TODO' | xargs -0 wc -l

# JSON output (machine-readable)
rg --json 'error' logs/ | jq 'select(.type == "match")'
```

### 7. Sorting & Limiting

```bash
# Sort results by file path
rg --sort path 'import'

# Sort by last modified time
rg --sort modified 'FIXME'

# Limit matches per file
rg -m 1 'class' -t py

# Limit total output with head
rg 'warning' logs/ | head -50

# Max depth of directory traversal
rg --max-depth 2 'README'
```

### 8. Multiline & Advanced

```bash
# Multiline: match a block
rg -U 'BEGIN\n.*\n.*\nEND' data.txt

# Match across lines with dot-matches-newline
rg -U '(?s)<div>.*?</div>' index.html

# Print lines that match ALL patterns (AND logic via piping)
rg 'error' log.txt | rg 'database'

# Search compressed files (requires rg 14+)
rg -z 'exception' logs.tar.gz

# Search only files modified in the last day (combine with find)
find . -mtime -1 -name '*.py' | xargs rg 'TODO'

# Follow symlinks
rg -L 'config' /etc/

# Respect a custom ignore file
rg --ignore-file .searchignore 'secret'
```

---

## Common Recipes

```bash
# Find function definitions in Python
rg 'def \w+\(' -t py

# Find all TODO/FIXME/HACK comments
rg '(TODO|FIXME|HACK):?' -t py -t js -t rs

# Find unused imports (print filenames for review)
rg -l 'import' src/ | xargs rg -L 'from'

# List all unique matched patterns (e.g., env vars)
rg -o --no-filename '\$[A-Z_]+' . | sort -u

# Find large numeric literals
rg -o '\b\d{7,}\b' src/

# Find files containing one pattern but not another
rg -l 'class Foo' src/ | xargs rg -L 'def bar'

# Preview a rename/replace before applying with sed
rg 'oldFunction' -r 'newFunction' src/
# Then apply:
rg -l 'oldFunction' src/ | xargs sed -i 's/oldFunction/newFunction/g'

# Search git history (combine with git log)
git log -p | rg 'dropped_table'

# Count TODO density by directory
rg -c 'TODO' src/ | sort -t: -k2 -nr | head -20

# Extract all URLs from a codebase
rg -o 'https?://[^\s"'"'"'<>]+' .
```

---

## Gotchas

- **Regex by default:** special characters (`.`, `(`, `*`, `?`, `+`, `{`, `[`) are regex metacharacters. Use `-F` for literal strings or escape them (`\.`, `\(`).
- **Smart-case is off by default** in non-interactive use. Pass `-S` explicitly when piping or scripting if you want it.
- **No in-place editing:** `-r` only transforms *output*. To actually modify files, pipe filenames through `sed` or similar.
- **`.gitignore` respected by default:** if matches are missing, the file might be git-ignored. Use `--no-ignore` or `-u` to include them.
- **Hidden files skipped by default:** dotfiles and dot-directories are excluded. Add `--hidden` to include them.
- **Line-oriented:** without `-U`, patterns can't span multiple lines. Add `-U` for multiline mode.
- **Binary files:** skipped silently by default. Use `-uuu` or `--binary` to search them.
