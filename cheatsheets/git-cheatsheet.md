# Git Cheat Sheet

## Configuration

```bash
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
git config --global core.editor "code --wait"
git config --list
```

## Repository Setup

```bash
git init
git clone <repository-url>
git clone <repository-url> --branch <branch-name>
git remote -v
git remote add origin <repository-url>
git remote set-url origin <new-url>
```

## Branching

```bash
git branch
git branch -a
git branch <branch-name>
git checkout <branch-name>
git checkout -b <branch-name>
git switch <branch-name>
git switch -c <branch-name>
git branch -d <branch-name>
git branch -D <branch-name>
git push origin --delete <branch-name>
```

## Staging and Committing

```bash
git status
git add <file>
git add .
git add -p
git commit -m "commit message"
git commit --amend -m "updated message"
git reset HEAD <file>
git restore --staged <file>
git restore <file>
```

## Stashing

```bash
git stash
git stash list
git stash pop
git stash apply stash@{0}
git stash drop stash@{0}
git stash clear
```

## Merging and Rebasing

```bash
git merge <branch-name>
git merge --no-ff <branch-name>
git rebase <branch-name>
git rebase -i HEAD~<n>
git merge --abort
git rebase --abort
git cherry-pick <commit-hash>
```

## History and Diffs

```bash
git log --oneline -n 20
git log --oneline --graph --all
git log --author="name"
git log --since="2024-01-01"
git diff
git diff --staged
git diff <branch1>..<branch2>
git show <commit-hash>
git blame <file>
```

## Remote Operations

```bash
git fetch
git fetch --all --prune
git pull
git pull --rebase
git push
git push -u origin <branch-name>
git push --force-with-lease
```

## Tags

```bash
git tag
git tag -a v1.0.0 -m "Release v1.0.0"
git tag -d <tag-name>
git push origin <tag-name>
git push origin --tags
```

## Undoing Changes

```bash
git revert <commit-hash>
git reset --soft HEAD~1
git reset --mixed HEAD~1
git reset --hard HEAD~1
git clean -fd
git reflog
git checkout <commit-hash> -- <file>
```

## Useful Aliases

```bash
git config --global alias.st "status"
git config --global alias.co "checkout"
git config --global alias.br "branch"
git config --global alias.lg "log --oneline --graph --all"
```