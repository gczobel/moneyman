import { readFileSync, writeFileSync } from "fs";
import { parseJsonc } from "../utils/jsonc.js";
const input = readFileSync("config copy.json", "utf-8");
const parsed = parseJsonc(input);
writeFileSync("configsingle.json", JSON.stringify(parsed));
console.log("Done: configsingle.json written");
