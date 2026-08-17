# macOS Xcode GitHub Actions

This project is controlled from Windows.

GitHub Actions runs the build on a GitHub-hosted macOS runner.

## Architecture

Windows
   |
   v
GitHub
   |
   v
macOS Runner
   |
   +-- macOS
   +-- Xcode
   +-- Swift
   +-- Build
   +-- Tests
   |
   v
Artifacts

## Workflow

The GitHub Actions workflow:

1. Starts macOS
2. Detects Xcode
3. Detects Swift
4. Resolves dependencies
5. Builds the project
6. Runs tests
7. Uploads artifacts

## Manual run

GitHub repository:

Actions
â†’ macOS Xcode Build
â†’ Run workflow

## Important

GitHub Actions is a remote macOS build environment.

It does NOT provide an interactive Xcode GUI desktop.
