# Pre-Push Checklist ✅

Complete this checklist before pushing your project to GitHub to ensure no sensitive data is exposed.

## 🔍 Verify Files Are Gitignored

Run these commands to verify sensitive files won't be committed:

```bash
# Check if .env is tracked (should return nothing)
git ls-files | grep "\.env$"

# Check if google-services.json is tracked (should return nothing)
git ls-files | grep "google-services.json"

# Check if GoogleService-Info.plist is tracked (should return nothing)  
git ls-files | grep "GoogleService-Info.plist"

# View what will be committed
git status

# Review staged changes
git diff --cached
```

## ✅ File Checklist

### ❌ NEVER Commit These (Should be in .gitignore)
- [ ] `.env` - Contains actual API keys
- [ ] `android/app/google-services.json` - Firebase Android config
- [ ] `ios/Runner/GoogleService-Info.plist` - Firebase iOS config

### ✅ Safe to Commit
- [ ] `.env.example` - Template with placeholder values
- [ ] `.gitignore` - Configured to exclude sensitive files
- [ ] `lib/config/app_config.dart` - Reads environment variables
- [ ] `lib/firebase_options.dart` - Uses AppConfig (no hardcoded keys)
- [ ] `lib/pages/new_request_page.dart` - Uses AppConfig for Maps API
- [ ] `README.md` - Project documentation
- [ ] `ENV_SETUP.md` - Setup instructions
- [ ] `SECURITY.md` - Security documentation
- [ ] `CHECKLIST.md` - This file

## 🔎 Verify No Hardcoded Keys

Search for any remaining hardcoded API keys:

```bash
# Search for potential API keys (should only find .env.example and documentation)
grep -r "AIzaSy" --exclude-dir=".git" --exclude="*.md" --exclude=".env"

# Check for Firebase keys
grep -r "firebase" -i --exclude-dir=".git" --exclude="*.md" --exclude=".env" | grep -i "key"
```

If you find any hardcoded keys in actual source files (not examples/docs), replace them with `AppConfig` references.

## 📝 Documentation Check

- [ ] `README.md` is updated with project information
- [ ] `ENV_SETUP.md` has clear setup instructions
- [ ] `SECURITY.md` explains security practices
- [ ] `.env.example` has all required variables (with placeholders)

## 🔐 Security Verification

- [ ] `.env` file contains your actual API keys (for local use)
- [ ] `.env.example` contains NO actual API keys (only placeholders)
- [ ] All API keys have been moved from source code to `.env`
- [ ] Code uses `AppConfig.variableName` to access keys
- [ ] No screenshots with visible API keys

## 🤝 Team Preparation

- [ ] Have a secure method to share API keys with team (password manager, encrypted chat)
- [ ] Team knows to copy `.env.example` to `.env` after cloning
- [ ] Team knows where to get Firebase config files

## 🚀 Git Commands

Once everything is verified:

```bash
# Initialize git (if not already done)
git init

# Add all files
git add .

# Verify what's being committed
git status

# Create initial commit
git commit -m "Initial commit - Fast Truck delivery management app"

# Add remote repository
git remote add origin <your-github-repository-url>

# Push to GitHub
git push -u origin main
```

## ⚠️ If You Find Exposed Keys

If you accidentally committed API keys:

1. **Immediately revoke** the exposed keys:
   - Google Cloud Console → Credentials → Delete key
   - Firebase Console → Project Settings → Regenerate keys

2. **Generate new keys**

3. **Update `.env`** with new keys

4. **Remove from git history** (if already committed):
   ```bash
   # Install BFG Repo-Cleaner
   # Use it to remove sensitive files from history
   
   # Or use git filter-branch (more complex)
   git filter-branch --force --index-filter \
     "git rm --cached --ignore-unmatch .env" \
     --prune-empty --tag-name-filter cat -- --all
   ```

5. **Force push** (destroys history):
   ```bash
   git push origin --force --all
   ```

## ✨ Final Check

Before pushing, answer these questions:

1. Can I see any actual API keys in files I'm about to commit? **NO** ✅
2. Is `.env` in my `.gitignore`? **YES** ✅
3. Have I tested that the app works with environment variables? **YES** ✅
4. Do I have `.env.example` with placeholder values? **YES** ✅
5. Is my documentation complete? **YES** ✅

If all answers are correct, you're ready to push! 🚀

## 📞 Need Help?

Review these documents:
- `ENV_SETUP.md` - For environment setup
- `SECURITY.md` - For security practices
- `README.md` - For general project info

---

**Remember:** It's much easier to avoid committing secrets than to remove them from git history!
