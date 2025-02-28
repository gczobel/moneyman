# Customizations

This document describes the customizations made to our fork of the moneyman repository and provides instructions for maintaining these customizations when syncing with the upstream repository.

## Customized Files

The following files have been customized in our fork:

1. `.github/workflows/scrape.yml` - Modified schedule for GitHub Actions
2. `.vscode/launch.json` - Custom VS Code debugging configuration

## Syncing with Upstream Repository

### Initial Setup (Only Needed Once)

1. Add the upstream repository as a remote:

   ```bash
   git remote add upstream git@github.com:daniel-hauser/moneyman.git
   ```

2. Verify the remotes:

   ```bash
   git remote -v
   ```

### Sync Process

Follow these steps when you need to sync with the upstream repository:

1. Create a backup branch of your current state:

   ```bash
   git checkout main
   git branch my-customized-backup
   ```

2. Fetch the latest changes from the upstream repository:

   ```bash
   git fetch upstream
   ```

3. Merge the upstream changes while preserving your own:

   ```bash
   git merge upstream/main
   ```

4. If there are conflicts, resolve them carefully to keep your customizations.
   For each file, you can choose:

   a. Keep your version:

   ```bash
   git checkout --ours path/to/file
   git add path/to/file
   ```

   b. Use upstream version:

   ```bash
   git checkout --theirs path/to/file
   git add path/to/file
   ```

   c. Manually edit the file to merge changes

5. For `package-lock.json` conflicts:

   ```bash
   # Accept package.json changes
   git checkout --theirs package.json
   git add package.json

   # Delete conflicted package-lock.json
   rm package-lock.json

   # Regenerate package-lock.json
   npm install

   # Add the new file
   git add package-lock.json
   ```

6. Complete the merge:

   ```bash
   git commit
   ```

7. Test that everything works:

   ```bash
   npm install
   npm test
   ```

8. If everything is working, push to your fork:

   ```bash
   git push origin main
   ```

### Reverting to Backup

If something goes wrong during the merge process, you can revert to your backup:

```bash
git checkout my-customized-backup
git branch -D main
git checkout -b main
git push -f origin main
```

### Reapplying Specific Customizations

If you need to reapply specific customizations after a merge:

1. For `.github/workflows/scrape.yml`:

   ```bash
   # If you want to use the upstream version as a base
   git checkout upstream/main -- .github/workflows/scrape.yml
   # Then edit the file to add your custom schedule
   ```

2. For `.vscode/launch.json`:

   ```bash
   # If your version was overwritten
   git checkout my-customized-backup -- .vscode/launch.json
   git add .vscode/launch.json
   git commit -m "Restore custom VS Code launch configuration"
   ```

## Future Improvements

To make maintenance easier in the future, consider:

1. Script the sync process for automation

   - Create a shell script that automates the fetch, merge, and specific file checkouts

2. Consider moving custom configurations to separate files that won't conflict, such as:

   - `.github/workflows/scrape.custom.yml`
   - `.vscode/launch.custom.json`

   Then modify the application to look for these custom files first.
