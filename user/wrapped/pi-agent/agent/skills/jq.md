---
name: jq
description: jq is a JSON processor, use it to filter, map and transform structured data.
---

# jq — Command-Line JSON Processor

## When to Use

Use `jq` whenever you need to extract, transform, filter, or reformat JSON data from files, API responses, or piped output.

**Trigger on:** pretty-printing JSON, extracting fields, filtering arrays, reshaping objects, converting JSON to CSV/TSV, merging JSON files, or any pipeline that passes structured data between commands.

**Don't use when:** the task requires complex multi-pass logic, stateful processing, or non-JSON formats — reach for Python/Node instead.

---

## Core Syntax

```
jq [OPTIONS] 'FILTER' [FILE...]
```

Input comes from a file argument or stdin via pipe. Output goes to stdout.

### Key Options

| Flag | Purpose |
|---|---|
| `-r` | Raw output (no quotes around strings) |
| `-e` | Set exit status based on output (useful in conditionals) |
| `-s` | Slurp: read entire input into a single array |
| `-n` | Null input: don't read stdin (use with `--argjson`, `inputs`) |
| `-c` | Compact output (one object per line, no whitespace) |
| `--arg k v` | Inject string variable `$k` with value `v` |
| `--argjson k v` | Inject parsed JSON variable `$k` |
| `--rawfile k f` | Bind file contents as string `$k` |
| `--jsonargs` | Treat remaining positional args as JSON values |

---

## Essential Patterns

### 1. Navigate & Extract

```bash
# Pretty-print
cat data.json | jq .

# Get a top-level field
jq '.name' file.json

# Nested field
jq '.config.database.host' file.json

# Multiple fields into a new object
jq '{name: .name, age: .age}' file.json
```

### 2. Arrays

```bash
# All elements
jq '.items[]' file.json

# First element
jq '.items[0]' file.json

# Slice (indices 2–4)
jq '.items[2:5]' file.json

# Length
jq '.items | length' file.json

# Pluck a field from each element
jq '.users[].email' file.json

# Collect back into an array
jq '[.users[].email]' file.json
```

### 3. Filter & Select

```bash
# Filter objects by condition
jq '.items[] | select(.price > 100)' file.json

# Negate
jq '.items[] | select(.status != "archived")' file.json

# Regex match on strings
jq '.items[] | select(.name | test("^prod-"))' file.json

# Multiple conditions
jq '.items[] | select(.price > 50 and .in_stock == true)' file.json

# Null-safe navigation (? suppresses errors on missing keys)
jq '.items[]? | .meta?.tags?[]?' file.json
```

### 4. Transform & Map

```bash
# Add/overwrite a field
jq '.items[] | . + {currency: "USD"}' file.json

# Remove a field
jq 'del(.items[].internal_id)' file.json

# Rename a key (create new, delete old)
jq '.items[] | .full_name = .name | del(.name)' file.json

# Map over array (concise)
jq '.items | map({id, upper_name: (.name | ascii_upcase)})' file.json

# Conditional value
jq '.items[] | .tier = (if .price > 100 then "premium" else "standard" end)' file.json
```

### 5. Aggregate & Reduce

```bash
# Count
jq '.items | length' file.json

# Sum a field
jq '[.items[].price] | add' file.json

# Min / Max
jq '[.items[].price] | min' file.json

# Group by a key
jq '.items | group_by(.category)' file.json

# Group then summarize
jq '.items | group_by(.category) | map({
  category: .[0].category,
  count: length,
  total: map(.price) | add
})' file.json

# Unique values
jq '[.items[].status] | unique' file.json

# Sort
jq '.items | sort_by(.price) | reverse' file.json
```

### 6. Reshape & Construct

```bash
# Build a completely new structure
jq '{
  total_users: (.users | length),
  emails: [.users[].email],
  admin_names: [.users[] | select(.role == "admin") | .name]
}' file.json

# Flatten nested arrays
jq '[.departments[].employees[]]' file.json

# Object from key-value pairs
jq '.items | map({(.id | tostring): .name}) | add' file.json

# Merge two files
jq -s '.[0] * .[1]' base.json overrides.json
```

### 7. Output Formats

```bash
# TSV (tab-separated)
jq -r '.users[] | [.name, .email, (.age | tostring)] | @tsv' file.json

# CSV
jq -r '.users[] | [.name, .email, (.age | tostring)] | @csv' file.json

# Raw lines (one value per line)
jq -r '.users[].email' file.json

# Compact JSON (one object per line, for JSONL)
jq -c '.items[]' file.json

# URI-encode a value
jq -r '.query | @uri' file.json

# HTML-escape
jq -r '.content | @html' file.json
```

### 8. Variables & Injection

```bash
# Pass a shell variable safely into the filter
jq --arg status "$STATUS" '.items[] | select(.status == $status)' file.json

# Pass a number/boolean/null
jq --argjson min_price 50 '.items[] | select(.price >= $min_price)' file.json

# Use env vars directly (jq 1.6+)
jq 'select(.region == env.AWS_REGION)' file.json
```

---

## Common Recipes

```bash
# Pretty-print an API response
curl -s https://api.example.com/data | jq .

# Extract nested IDs from paginated response
curl -s "$URL" | jq -r '.data.results[].id'

# Convert JSONL to a JSON array
jq -s '.' input.jsonl > output.json

# Convert JSON array to JSONL
jq -c '.[]' input.json > output.jsonl

# Diff two JSON files (shallow key comparison)
diff <(jq -S . a.json) <(jq -S . b.json)

# Update a value in-place (sponge from moreutils, or temp file)
jq '.version = "2.0.0"' package.json > tmp && mv tmp package.json

# Recursively find all keys named "id" at any depth
jq '.. | .id? // empty' file.json

# Merge all JSON files in a directory
jq -s 'add' *.json > merged.json
```

---

## Gotchas

- **Strings vs numbers:** `"42"` and `42` are different. Use `tonumber` / `tostring` to convert.
- **Null propagation:** accessing a missing key returns `null`, not an error. Chain with `// "default"` for fallback values.
- **Exit codes:** `jq` exits 0 on success even if output is `null` or `false`. Use `-e` to exit non-zero when the output is `false` or `null`.
- **Large files:** `jq` loads the full input into memory. For multi-GB files, use streaming (`--stream`) or line-by-line JSONL processing with `-c`.
- **In-place editing:** `jq` has no `-i` flag. Write to a temp file and `mv` it back.
