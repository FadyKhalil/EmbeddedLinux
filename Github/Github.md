# Git Quick Overview

## Introduction

Git is a distributed version control system widely used in software development to track changes in source code during the development process. It allows multiple contributors to collaborate on a project seamlessly.

## Basic Concepts

- **Repository (Repo):** A folder or storage space where your project lives, containing all the files and their complete history.
- **Commit:** A snapshot of your repository at a specific point in time. It records changes made to files.
- **Branch:** A separate line of development. It allows you to work on features or fixes without affecting the main codebase.
- **Merge:** Combining changes from different branches.
- **Pull Request (PR):** Proposing changes and requesting them to be merged into a branch.

## Essential Commands

- **`git init`:** Initializes a new Git repository in the current directory.
- **`git clone [url]`:** Creates a local copy of a remote repository.
- **`git add [file]`:** Stages changes for the next commit.
- **`git commit -m "message"`:** Records changes to the repository with a descriptive message.
- **`git status`:** Shows the status of changes as untracked, modified, or staged.
- **`git log`:** Displays a log of commits.
- **`git branch`:** Lists all branches, indicating the current one with an asterisk.
- **`git checkout [branch]`:** Switches to a different branch.
- **`git merge [branch]`:** Integrates changes from one branch into another.
- **`git pull origin [branch]`:** Fetches changes from a remote repository and merges them into the current branch.
- **`git push origin [branch]`:** Pushes changes to a remote repository.

## Workflow Example

1. **Initialize Repository:**

   ```bash
   git init
   ```

2. **Create a Branch:**

   ```bash
   git branch feature-branch
   git checkout feature-branch
   ```

3. **Make Changes:**

   ```bash
   # Make changes to files
   git add .
   git commit -m "Add new feature"
   ```

4. **Merge Changes:**

   ```bash
   git checkout main
   git merge feature-branch
   ```

5. **Push Changes:**

   ```bash
   git push origin main
   ```

This is a simplified overview of Git.



# Downloading and Installing Git Bash

## Steps

### Step 1: Download

1. Visit the [Git official website](https://git-scm.com/).
2. Click on the "Download" button.

### Step 2: Choose Download Option

Choose the appropriate version for your operating system (Windows in this case).

### Step 3: Run the Installer

1. Open the downloaded executable file (e.g., `Git-2.x.x-64-bit.exe` for a 64-bit system).
2. The installer will guide you through the setup process.

### Step 4 : Launch Git Bash

1. Once the installation is complete, find the Git Bash shortcut on your desktop or in the Start menu.
2. Open Git Bash.

### Step 5: Verify Installation

Open Git Bash and enter the following command to verify the installation:

```
git --version
```

If Git is installed successfully, you should see the installed Git version.

Congratulations! You've successfully downloaded and installed Git Bash on your Windows system. You can now use Git commands in the Git Bash terminal.

# Configuring Git Author Information

When working with Git, it's essential to configure your author name and email to associate your commits with your identity. This information is included in each commit and is visible in the project's version history. Here's how you can configure your author information:

## Step 1: Open Git Bash or Terminal

Open Git Bash or your terminal on your local machine.

## Step 2: Use Git Config Command

Git uses the `git config` command to set configuration options. Use the following commands to configure your author name and email:

```bash
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

Replace "Your Name" with your actual name and "[your.email@example.com](mailto:your.email@example.com)" with your actual email address.

- The `--global` flag sets these configurations globally, meaning they will be applied to all your Git repositories on this machine.

## Step 3: Verify Configuration

To verify that your configuration changes were successful, you can use the following command:

```bash
git config --global --get user.name
git config --global --get user.email
```

These commands will display the configured name and email, respectively.



# Topics to Discuss

- [ ] Initialize local repo

  - ```bash
    git init
    ```

- [ ] Track and Untrack Files

  - ```bash
    git add
    ```

- [ ] Ignore file (.gitignore)

- [ ] stage and commit

  - ```bash
    git commit -a -m "your commit message"
    ```

- [ ] Amend Commit

  - ```bash
    git commit -m "new commit message" --amend
    ```

- [ ] View Change in commits

  - ```bash
    git log -p
    ```

- [ ] change file and view differences

  - ```bash
    git diff
    ```

- [ ] Restore and rename files

  - ```bash
    git mv <fileName> <newFileName>
    ```

- [ ] Commit History

- [ ] Branches

- [ ] Merge Branch

- [ ] Merge Conflicts

- [ ] Push local repo to GitHub

- [ ] Pull Requests



# Initializing a Repository on GitHub

## Overview

Initializing a repository on GitHub involves creating a new repository to host your project. Here's a step-by-step guide to help you initialize a repository on GitHub.

### Step 1: Sign in to GitHub

If you don't have a GitHub account, you'll need to sign up. If you already have an account, sign in to your GitHub account.

### Step 2: Create a New Repository

1. On the GitHub homepage, click on the "+" sign in the upper right corner.
2. From the dropdown, select "New repository."

### Step 3: Fill in Repository Details

1. **Repository Name:** Enter a name for your repository. This will also become the project's URL (e.g., `my-first-repo`).
2. **Description (optional):** Provide a brief description of your project.
3. **Public/Private:** Choose whether your repository will be public (visible to everyone) or private (accessible only to you and collaborators).
4. **Initialize this repository with a README:** You can choose to initialize your repository with a README file. This is optional but can be useful to provide information about your project.

### Step 4: Choose a License, .gitignore, or Template (Optional)

- **License:** Choose a license for your project. This is optional, but it's good practice to specify the terms under which others can use, modify, and distribute your software.
- **.gitignore:** Select a .gitignore file to determine which files and directories should be ignored by Git. This depends on your project type (e.g., Python, Node, Java).
- **Template:** If your project fits a specific category (e.g., Python library, Node module), you can choose a template to initialize your repository with files and settings tailored to that category.

### Step 5: Create Repository

Click the "Create repository" button to finalize the process.

### Step 6: Copy the Repository URL

After creating the repository, you'll be redirected to its main page. Copy the repository URL from the "Quick setup" section.

### Step 7: Initialize a Local Git Repository

1. Open a terminal or Git Bash on your local machine.

2. Navigate to your project directory using the `cd` command.

3. Initialize a Git repository using the following commands:

   ```
   git init
   git remote add origin <paste_repository_url_here>
   ```

### Step 8: Add, Commit, and Push

1. Add your files to the repository:

   ```
   git add .
   ```

2. Commit the changes:

   ```
   git commit -m "Initial commit"
   ```

3. Push the changes to GitHub:

   ```
   git push -u origin main
   ```

   (Note: If you initialized with a different branch name, replace `main`with your branch name.)