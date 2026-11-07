---
name: config-single-line
description: Regenerate configsingle.json as a single-line (minified) copy of config.jsonc in the moneyman repo. Use only when the user asks to run it, refresh configsingle.json, or minify/compact config.jsonc into one line. Do not run it on your own initiative.
---

# Config to single line

Makes `configsingle.json` a one-line JSON copy of `config.jsonc`. The source is JSONC (JSON with comments and optional trailing commas), so it is not valid strict JSON and `jq` cannot read it. Both files are at the repo root (`/workspaces/moneyman`). `configsingle.json` is listed in `.gitignore` because it holds bank and credit card details.

## Steps

1. Work from the repo root.
2. Convert with the `jsonc-parser` package, which is a declared dependency in `package.json`. It strips comments and trailing commas, and it reports parse errors instead of guessing:
   ```bash
   node -e 'const fs=require("fs");const {parse}=require("jsonc-parser");const errs=[];const data=parse(fs.readFileSync("config.jsonc","utf8"),errs,{allowTrailingComma:true});if(errs.length){console.error("config.jsonc has "+errs.length+" parse error(s); configsingle.json not written");process.exit(1)}fs.writeFileSync("configsingle.json",JSON.stringify(data)+"\n")'
   ```
   The conversion fails without writing anything if `config.jsonc` is malformed. Do not print the error details, since they can include fragments of the file.
3. Verify that the output is one line and parses to the same data:
   ```bash
   wc -l configsingle.json
   node -e 'const fs=require("fs");const {parse}=require("jsonc-parser");console.log(JSON.stringify(parse(fs.readFileSync("config.jsonc","utf8"),[],{allowTrailingComma:true}))===JSON.stringify(JSON.parse(fs.readFileSync("configsingle.json","utf8"))))'
   ```
   The line count should be 1 and the second command should print `true`.

## Rules

- Never print the contents of either file in the chat. They contain account and card data, so report only pass/fail and the line count.
- Do not commit or push the output. `configsingle.json` is gitignored.
- If `node_modules` is missing, run `npm install` first so `jsonc-parser` is available, then run the steps.
