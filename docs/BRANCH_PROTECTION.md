# Required GitHub Branch Protection Settings

To ensure that only PRs can merge code into main by rebasing and that every PR merged into main triggers the CI/CD pipeline, configure the following branch protection rules for the `main` branch:

## Branch Protection Rules for `main` Branch

### 1. Require a pull request before merging
- ✅ **Require pull request reviews before merging**
  - Require approval from at least 1 reviewer
  - Optionally: Require review from Code Owners

### 2. Require status checks to pass before merging
- ✅ **Require status checks to pass before merging**
  - Select the CI/CD workflow checks:
    - Test & Lint (test-and-lint job)
    - Build Android (build-android job) - for main branch builds
  - Optionally: Require branches to be up to date before merging

### 3. Require linear history
- ✅ **Require linear history**
  - Prevents merge commits, enforces rebasing or squash merging
  - Ensures clean, linear commit history

### 4. Restrict who can push to matching branches
- ✅ **Restrict who can push to matching branches**
  - Disable direct pushes to main branch
  - Allow only specific roles/teams to bypass protection (if needed)
  - Typically: Only allow repository administrators to bypass (for emergency fixes)

### 5. Additional recommended settings
- ✅ **Include administrators**
  - Apply rules to repository administrators as well
- ✅ **Restrict deletions**
  - Prevent accidental deletion of main branch
- ✅ **Require conversation resolution**
  - Require all comments to be resolved before merging

## How to Configure

1. Go to your repository on GitHub
2. Navigate to Settings → Branches → Branch protection rules
3. Click "Add rule" or edit the existing rule for `main` branch
4. Enter `main` as the branch name pattern
5. Configure the settings as described above
6. Save changes

## Verification

After configuration:
- Direct pushes to main will be blocked
- Only pull requests can be merged into main
- Merges will require passing all status checks
- Merge commits will be prevented (forces rebase or squash merge)
- Every merge to main will trigger the CI/CD pipeline (including Android build and deployment)