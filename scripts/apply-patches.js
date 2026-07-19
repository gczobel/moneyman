import { execFileSync } from "child_process";
import { readdirSync } from "fs";

// Apply patches that patch-package doesn't recognise (those with extra suffixes like +yahav, +isracard).
// patch-package only handles {name}+{version}.patch; named variants are applied here via git apply.
const named = readdirSync("patches").filter((f) => {
  const parts = f.replace(".patch", "").split("+");
  return parts.length > 2; // e.g. israeli-bank-scrapers+6.7.3+yahav
});

for (const patch of named) {
  try {
    execFileSync("git", ["apply", `patches/${patch}`], { stdio: "inherit" });
    console.log(`✔ Applied patches/${patch}`);
  } catch {
    console.warn(`⚠ patches/${patch} already applied or failed — skipping`);
  }
}
