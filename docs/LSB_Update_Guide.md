# LSB Update Guide - Manual Process

## Overview
This guide helps you safely update your FFXI private server with the latest LandSandBoat (LSB) changes while preserving all your custom modifications.

## Prerequisites
- Your server repository is set up with LSB as upstream
- You have custom modifications in `modules/custom/` and custom commands in `scripts/commands/`
- GitHub repository with branch protection enabled

---

## Step 1: Set Up Upstream Tracking (One-time setup)

If you haven't already set up LSB as upstream:

```bash
cd ~/server
git remote add upstream https://github.com/LandSandBoat/server.git
git remote -v
```

You should see:
```
origin    https://github.com/YOUR-USERNAME/YOUR-REPO.git (your repo)
upstream  https://github.com/LandSandBoat/server.git (LSB repo)
```

---

## Step 2: Check for LSB Updates

```bash
# Fetch latest changes from LSB
git fetch upstream

# See what's new in LSB that you don't have
git log HEAD..upstream/base --oneline -20

# See which files changed
git diff HEAD..upstream/base --name-only

# See detailed statistics of changes
git diff HEAD..upstream/base --stat | grep -v " 0$"
```

### Understanding the Output:
- **New commits:** Shows what LSB has added since your last update
- **Changed files:** Shows which files will be modified
- **Statistics:** Shows how many lines changed in each file

### Key Things to Look For:
- New content (quests, ENMs, zones)
- Bug fixes and improvements
- Database changes (SQL files)
- New features

---

## Step 3: Review Specific Changes

### Check What Will Happen to Your Custom Files:
```bash
# Check if your custom modules will be affected
git diff HEAD..upstream/base modules/custom/

# Check if your custom commands will be affected  
git diff HEAD..upstream/base scripts/commands/createnpc.lua
git diff HEAD..upstream/base scripts/commands/home.lua
# (repeat for other custom commands)
```

### Look at Specific New Features:
```bash
# Example: Check new quest content
git log upstream/base --oneline --grep="quest"

# Example: Check recent battlefields/ENMs
git log upstream/base --oneline -- scripts/battlefields/

# View specific commits
git show COMMIT_HASH
```

---

## Step 4: Backup Your Custom Files

**ALWAYS backup before merging!**

```bash
# Create backup directory
mkdir ~/custom_backup

# Backup custom modules
cp -r modules/custom/ ~/custom_backup/

# Backup custom commands
mkdir ~/custom_backup/commands
cp scripts/commands/createnpc.lua ~/custom_backup/commands/ 2>/dev/null || true
cp scripts/commands/home.lua ~/custom_backup/commands/ 2>/dev/null || true
cp scripts/commands/merit.lua ~/custom_backup/commands/ 2>/dev/null || true
cp scripts/commands/relic.lua ~/custom_backup/commands/ 2>/dev/null || true
cp scripts/commands/sanction.lua ~/custom_backup/commands/ 2>/dev/null || true
cp scripts/commands/signet.lua ~/custom_backup/commands/ 2>/dev/null || true
cp scripts/commands/warp.lua ~/custom_backup/commands/ 2>/dev/null || true
# Add any other custom commands you have

# Verify backup
ls -la ~/custom_backup/
ls -la ~/custom_backup/commands/
```

---

## Step 5: Create Test Branch and Merge

```bash
# Create test branch for safe merging
git checkout -b lsb-update-test

# Merge LSB changes (expect conflicts)
git merge upstream/base
```

### If Merge Conflicts Occur:
```bash
# Accept LSB's version for all conflicts
git checkout --theirs .

# If there are delete conflicts (files LSB removed):
git rm path/to/conflicted/file.lua

# Add all changes and commit
git add .
git commit -m "Merge LSB updates - custom files to be restored next"
```

---

## Step 6: Restore Your Custom Files

```bash
# Restore your custom modules
cp -r ~/custom_backup/custom/ modules/

# Restore your custom commands
cp ~/custom_backup/commands/* scripts/commands/

# Verify restoration
ls -la modules/custom/lua/
ls -la scripts/commands/ | grep -E "(createnpc|home|merit|relic|sanction|signet|warp)"

# Add and commit your custom files
git add modules/custom/
git add scripts/commands/
git commit -m "Restore custom modifications after LSB merge"
```

---

## Step 7: Test Your Server

```bash
# Compile/build your server if needed
# Start your server components
# Test basic functionality
# Test your custom features
```

**Critical Tests:**
- Server starts without errors
- Custom NPCs work (armor shops, etc.)
- Custom commands function
- New LSB content is available
- Database connections work

---

## Step 8: Database Updates with dbtool.py

**After confirming server works, update database:**

```bash
# Navigate to tools directory
cd ~/server/tools

# Run database update (creates backup automatically)
python3 dbtool.py update

# Or use interactive mode
python3 dbtool.py
# Then select "1. Update"
```

### What dbtool.py Does:
- ✅ Creates automatic database backup
- ✅ Imports new SQL files from LSB
- ✅ Runs database migrations
- ✅ Updates client version settings
- ✅ Handles table structure changes

### If dbtool.py Fails:
- Check `server/sql/backups/` for automatic backup
- Review error messages carefully
- Restore from backup if needed: `python3 dbtool.py` → "4. Restore/Import"

---

## Step 9: Push Updates to GitHub

### Option A: Temporarily Disable Branch Protection (Quickest)
1. Go to GitHub → Settings → Branches
2. Delete protection rule for `main` branch
3. Push changes:
   ```bash
   git checkout main
   git merge lsb-update-test
   git push origin main
   ```
4. Re-enable branch protection

### Option B: Use Pull Request (Proper workflow)
```bash
# Push test branch to GitHub
git push origin lsb-update-test:lsb-updates

# Go to GitHub web interface
# Create Pull Request from lsb-updates to main
# Review and merge the PR
```

---

## Step 10: Final Cleanup

```bash
# Switch back to main
git checkout main

# Delete test branch
git branch -d lsb-update-test

# Remove backup directory
rm -rf ~/custom_backup

# Verify final status
git status
```

### Optional: Clean Up Submodules
```bash
# If submodules show as modified
git submodule update --recursive --force

# Or commit submodule changes if intentional
git add losmeshes navmeshes
git commit -m "Update submodules after LSB merge"
git push origin main
```

---

## Troubleshooting

### If Something Goes Wrong:
```bash
# Abort merge and start over
git merge --abort
git checkout main
git branch -D lsb-update-test

# Restore from backup
cp -r ~/custom_backup/custom/ modules/
cp ~/custom_backup/commands/* scripts/commands/
```

### If Database Update Fails:
```bash
# Restore database from backup
cd ~/server/tools
python3 dbtool.py
# Select "4. Restore/Import"
# Choose the backup created before update
```

### If Server Won't Start:
1. Check server logs for errors
2. Verify custom files are in place
3. Check database connection
4. Consider reverting to previous git commit

---

## Best Practices

### Before Every Update:
- ✅ Test current server works
- ✅ Backup database manually: `python3 dbtool.py backup`
- ✅ Note current git commit: `git log --oneline -1`
- ✅ Review LSB changelog/commits

### During Update:
- ✅ Always use test branch first
- ✅ Verify custom files restored correctly
- ✅ Test thoroughly before pushing to main
- ✅ Update database after code changes

### After Update:
- ✅ Monitor server for issues
- ✅ Test new LSB features
- ✅ Document any conflicts encountered
- ✅ Update your own documentation

---

## Quick Reference Commands

```bash
# Check for updates
git fetch upstream && git log HEAD..upstream/base --oneline -10

# Emergency rollback
git reset --hard HEAD~1  # Go back one commit
git push origin main --force  # (disable protection first)

# Database backup
cd ~/server/tools && python3 dbtool.py backup

# View what changed in last update
git diff HEAD~1 --stat
```

---

## When to Update

### Good Times to Update:
- LSB releases new content you want
- Critical bug fixes are available
- Security improvements are released
- During scheduled maintenance windows

### Avoid Updating When:
- Server is heavily used
- In middle of custom development
- Before important events
- Without time to properly test

---

*This guide preserves your custom modifications while keeping you current with LandSandBoat improvements. Always test thoroughly and maintain backups!*
