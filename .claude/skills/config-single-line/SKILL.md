---
name: config-single-line
description: Regenerate configsingle.json as a single-line (minified) copy of config.json in the moneyman repo. Use only when the user asks to run it, refresh configsingle.json, or minify/compact config.json into one line. Do not run it on your own initiative.
---

# Config to single line

Makes `configsingle.json` a one-line JSON copy of `config.json`. Both files are at the repo root (`/workspaces/moneyman`) and are listed in `.gitignore`, because they hold bank and credit card details.

## Steps

1. Work from the repo root.
2. Run:
   ```bash
   jq -c . config.json > configsingle.json
   ```
   `jq -c` compacts the JSON onto one line and fails if `config.json` is not valid JSON.
3. Verify that the output is one line and parses to the same data:
   ```bash
   wc -l configsingle.json
   node -e 'const fs=require("fs");console.log(JSON.stringify(JSON.parse(fs.readFileSync("config.json","utf8")))===JSON.stringify(JSON.parse(fs.readFileSync("configsingle.json","utf8"))))'
   ```
   The line count should be 1 and the second command should print `true`.

## Rules

- Never print the contents of either file in the chat. They contain account and card data, so report only pass/fail and the line count.
- Do not commit or push the output. Both files are gitignored.
- If `jq` is missing, fall back to `node -e 'const fs=require("fs");fs.writeFileSync("configsingle.json", JSON.stringify(JSON.parse(fs.readFileSync("config.json","utf8"))))'`.
