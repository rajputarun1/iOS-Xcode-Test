# ============================================================
# GitHub macOS / Xcode Automation
# Windows PowerShell
#
# Current project:
# C:\Users\rajpu\OneDrive\Documents\iOS-Xcode-Test
# ============================================================

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "       GitHub macOS / Xcode Automation Setup" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

# ============================================================
# 1. PROJECT DIRECTORY
# ============================================================

Write-Host "[1/10] Detecting project directory..." -ForegroundColor Yellow

$ProjectPath = (Get-Location).Path
$ProjectName = Split-Path -Leaf $ProjectPath

Write-Host ""
Write-Host "Project name:" -ForegroundColor Gray
Write-Host $ProjectName -ForegroundColor Green

Write-Host "Project path:" -ForegroundColor Gray
Write-Host $ProjectPath -ForegroundColor Green
Write-Host ""

if (-not (Test-Path -LiteralPath $ProjectPath -PathType Container)) {
    throw "Project directory does not exist: $ProjectPath"
}

# ============================================================
# HELPER FUNCTION
# ============================================================

function Ensure-Directory {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Path
    )

    if (-not (Test-Path -LiteralPath $Path -PathType Container)) {

        Write-Host "Creating directory:" -ForegroundColor DarkGray
        Write-Host "  $Path" -ForegroundColor DarkGray

        New-Item `
            -ItemType Directory `
            -Path $Path `
            -Force `
            -ErrorAction Stop | Out-Null
    }

    if (-not (Test-Path -LiteralPath $Path -PathType Container)) {
        throw "Failed to create directory: $Path"
    }
}

# ============================================================
# 2. CHECK GIT
# ============================================================

Write-Host "[2/10] Checking Git..." -ForegroundColor Yellow

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {

    Write-Host ""
    Write-Host "Git is not installed." -ForegroundColor Red
    Write-Host ""
    Write-Host "Install Git for Windows:" -ForegroundColor Yellow
    Write-Host "https://git-scm.com/download/win" -ForegroundColor Cyan
    Write-Host ""

    exit 1
}

Write-Host "Git found:" -ForegroundColor Green
git --version

# ============================================================
# 3. CHECK / INSTALL GITHUB CLI
# ============================================================

Write-Host ""
Write-Host "[3/10] Checking GitHub CLI..." -ForegroundColor Yellow

$GH = Get-Command gh -ErrorAction SilentlyContinue

if (-not $GH) {

    Write-Host ""
    Write-Host "GitHub CLI is not installed." -ForegroundColor Yellow

    $Winget = Get-Command winget -ErrorAction SilentlyContinue

    if ($Winget) {

        Write-Host ""
        Write-Host "Installing GitHub CLI using winget..." -ForegroundColor Yellow
        Write-Host ""

        winget install `
            --id GitHub.cli `
            --accept-source-agreements `
            --accept-package-agreements

        # Refresh PATH
        $env:Path =
            [System.Environment]::GetEnvironmentVariable(
                "Path",
                "Machine"
            ) + ";" +
            [System.Environment]::GetEnvironmentVariable(
                "Path",
                "User"
            )

        $GH = Get-Command gh -ErrorAction SilentlyContinue
    }

    if (-not $GH) {

        Write-Host ""
        Write-Host "GitHub CLI could not be found." -ForegroundColor Red
        Write-Host ""
        Write-Host "Install GitHub CLI from:" -ForegroundColor Yellow
        Write-Host "https://cli.github.com/" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "Then CLOSE PowerShell, open a NEW PowerShell," -ForegroundColor Yellow
        Write-Host "and run this script again." -ForegroundColor Yellow
        Write-Host ""

        exit 1
    }
}

Write-Host "GitHub CLI found:" -ForegroundColor Green
gh --version | Select-Object -First 1

# ============================================================
# 4. CREATE SWIFT PROJECT
# ============================================================

Write-Host ""
Write-Host "[4/10] Creating Swift project..." -ForegroundColor Yellow
Write-Host ""

# ------------------------------------------------------------
# Create Sources directory
# ------------------------------------------------------------

$SourcesPath = Join-Path $ProjectPath "Sources"

Ensure-Directory $SourcesPath

# ------------------------------------------------------------
# Create Sources/MyApp directory
# ------------------------------------------------------------

$MyAppSourcePath = Join-Path $SourcesPath "MyApp"

Ensure-Directory $MyAppSourcePath

# ------------------------------------------------------------
# Create Tests directory
# ------------------------------------------------------------

$TestsPath = Join-Path $ProjectPath "Tests"

Ensure-Directory $TestsPath

# ------------------------------------------------------------
# Create Tests/MyAppTests directory
# ------------------------------------------------------------

$MyAppTestsPath = Join-Path $TestsPath "MyAppTests"

Ensure-Directory $MyAppTestsPath

Write-Host ""
Write-Host "Directories verified:" -ForegroundColor Green

Write-Host "  $SourcesPath" -ForegroundColor DarkGray
Write-Host "  $MyAppSourcePath" -ForegroundColor DarkGray
Write-Host "  $TestsPath" -ForegroundColor DarkGray
Write-Host "  $MyAppTestsPath" -ForegroundColor DarkGray

# ============================================================
# WRITE SWIFT SOURCE
# ============================================================

$SwiftFile = Join-Path $MyAppSourcePath "MyApp.swift"

$SwiftSource = @'
import Foundation

public struct MyApp {

    public init() {}

    public func message() -> String {
        return "Hello from Xcode on macOS!"
    }
}
'@

Set-Content `
    -LiteralPath $SwiftFile `
    -Value $SwiftSource `
    -Encoding UTF8 `
    -Force

if (-not (Test-Path -LiteralPath $SwiftFile -PathType Leaf)) {
    throw "Failed to create Swift source file: $SwiftFile"
}

Write-Host ""
Write-Host "Created:" -ForegroundColor Green
Write-Host "  $SwiftFile" -ForegroundColor Green

# ============================================================
# WRITE TEST FILE
# ============================================================

$TestFile = Join-Path $MyAppTestsPath "MyAppTests.swift"

$SwiftTests = @'
import XCTest
@testable import MyApp

final class MyAppTests: XCTestCase {

    func testMessage() {

        let app = MyApp()

        XCTAssertEqual(
            app.message(),
            "Hello from Xcode on macOS!"
        )
    }
}
'@

Set-Content `
    -LiteralPath $TestFile `
    -Value $SwiftTests `
    -Encoding UTF8 `
    -Force

if (-not (Test-Path -LiteralPath $TestFile -PathType Leaf)) {
    throw "Failed to create test file: $TestFile"
}

Write-Host "Created:" -ForegroundColor Green
Write-Host "  $TestFile" -ForegroundColor Green

# ============================================================
# PACKAGE.SWIFT
# ============================================================

$PackageFile = Join-Path $ProjectPath "Package.swift"

$PackageSwift = @'
// swift-tools-version: 5.9

import PackageDescription

let package = Package(

    name: "MyApp",

    products: [

        .library(
            name: "MyApp",
            targets: ["MyApp"]
        )
    ],

    targets: [

        .target(
            name: "MyApp"
        ),

        .testTarget(
            name: "MyAppTests",
            dependencies: ["MyApp"]
        )
    ]
)
'@

Set-Content `
    -LiteralPath $PackageFile `
    -Value $PackageSwift `
    -Encoding UTF8 `
    -Force

Write-Host "Created:" -ForegroundColor Green
Write-Host "  $PackageFile" -ForegroundColor Green

# ============================================================
# 5. GITHUB ACTIONS
# ============================================================

Write-Host ""
Write-Host "[5/10] Creating GitHub Actions workflow..." -ForegroundColor Yellow

$GitHubDirectory = Join-Path $ProjectPath ".github"

Ensure-Directory $GitHubDirectory

$WorkflowDirectory = Join-Path $GitHubDirectory "workflows"

Ensure-Directory $WorkflowDirectory

$WorkflowFile = Join-Path $WorkflowDirectory "xcode.yml"

$Workflow = @'
name: macOS Xcode Build

on:

  push:
    branches:
      - main

  pull_request:
    branches:
      - main

  workflow_dispatch:

jobs:

  build:

    runs-on: macos-latest

    steps:

      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Show macOS version
        run: |
          echo "=============================="
          echo "macOS"
          echo "=============================="
          sw_vers

      - name: Show Xcode version
        run: |
          echo "=============================="
          echo "Xcode"
          echo "=============================="
          xcodebuild -version

      - name: Show Swift version
        run: |
          echo "=============================="
          echo "Swift"
          echo "=============================="
          swift --version

      - name: Show available Xcode
        run: |
          echo "=============================="
          echo "Available Xcode"
          echo "=============================="
          ls -la /Applications | grep -i Xcode || true

      - name: Resolve dependencies
        run: |
          swift package resolve

      - name: Build Swift project
        run: |
          swift build -c release

      - name: Run tests
        run: |
          swift test

      - name: Prepare artifacts
        run: |
          mkdir -p artifacts

      - name: Save macOS information
        run: |
          sw_vers > artifacts/macos.txt

      - name: Save Xcode information
        run: |
          xcodebuild -version > artifacts/xcode.txt

      - name: Save Swift information
        run: |
          swift --version > artifacts/swift.txt

      - name: Upload artifacts
        uses: actions/upload-artifact@v4

        with:
          name: macos-xcode-build
          path: artifacts/
'@

Set-Content `
    -LiteralPath $WorkflowFile `
    -Value $Workflow `
    -Encoding UTF8 `
    -Force

Write-Host ""
Write-Host "Created:" -ForegroundColor Green
Write-Host "  $WorkflowFile" -ForegroundColor Green

# ============================================================
# 6. README
# ============================================================

Write-Host ""
Write-Host "[6/10] Creating README..." -ForegroundColor Yellow

$ReadmeFile = Join-Path $ProjectPath "README.md"

$Readme = @'
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
→ macOS Xcode Build
→ Run workflow

## Important

GitHub Actions is a remote macOS build environment.

It does NOT provide an interactive Xcode GUI desktop.
'@

Set-Content `
    -LiteralPath $ReadmeFile `
    -Value $Readme `
    -Encoding UTF8 `
    -Force

# ============================================================
# 7. GITIGNORE
# ============================================================

Write-Host ""
Write-Host "[7/10] Creating .gitignore..." -ForegroundColor Yellow

$GitIgnoreFile = Join-Path $ProjectPath ".gitignore"

$GitIgnore = @'
.DS_Store
.build/
DerivedData/
xcuserdata/
*.xcuserstate
*.xcworkspace/xcuserdata/
'@

Set-Content `
    -LiteralPath $GitIgnoreFile `
    -Value $GitIgnore `
    -Encoding UTF8 `
    -Force

# ============================================================
# 8. GIT
# ============================================================

Write-Host ""
Write-Host "[8/10] Setting up Git repository..." -ForegroundColor Yellow

$GitDirectory = Join-Path $ProjectPath ".git"

if (-not (Test-Path -LiteralPath $GitDirectory -PathType Container)) {

    git init

}
else {

    Write-Host "Git repository already exists." -ForegroundColor Yellow
}

git branch -M main

git add .

$GitStatus = git status --porcelain

if ($GitStatus) {

    git commit -m "Initial macOS Xcode GitHub Actions setup"

}
else {

    Write-Host "No changes to commit." -ForegroundColor Yellow
}

# ============================================================
# 9. GITHUB LOGIN
# ============================================================

Write-Host ""
Write-Host "[9/10] Checking GitHub authentication..." -ForegroundColor Yellow

gh auth status 2>&1 | Out-Null

if ($LASTEXITCODE -ne 0) {

    Write-Host ""
    Write-Host "GitHub login is required." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "A browser window will open." -ForegroundColor Cyan
    Write-Host ""

    gh auth login

    if ($LASTEXITCODE -ne 0) {

        Write-Host ""
        Write-Host "GitHub login failed." -ForegroundColor Red
        exit 1
    }
}

Write-Host ""
Write-Host "GitHub authentication successful." -ForegroundColor Green

# ============================================================
# 10. CREATE / PUSH REPOSITORY
# ============================================================

Write-Host ""
Write-Host "[10/10] Creating / updating GitHub repository..." -ForegroundColor Yellow

$ExistingRemote = git remote get-url origin 2>$null

if ($ExistingRemote) {

    Write-Host ""
    Write-Host "Existing GitHub remote:" -ForegroundColor Yellow
    Write-Host $ExistingRemote -ForegroundColor Cyan
    Write-Host ""

    git push -u origin main

}
else {

    Write-Host ""
    Write-Host "Creating public repository:" -ForegroundColor Yellow
    Write-Host $ProjectName -ForegroundColor Cyan
    Write-Host ""

    gh repo create $ProjectName `
        --public `
        --source="$ProjectPath" `
        --remote=origin `
        --push

    if ($LASTEXITCODE -ne 0) {

        Write-Host ""
        Write-Host "GitHub repository creation failed." -ForegroundColor Red
        Write-Host ""
        exit 1
    }
}

# ============================================================
# FINAL
# ============================================================

Write-Host ""
Write-Host "============================================================" -ForegroundColor Green
Write-Host "                 SETUP COMPLETED" -ForegroundColor Green
Write-Host "============================================================" -ForegroundColor Green
Write-Host ""

Write-Host "Local project:" -ForegroundColor Yellow
Write-Host $ProjectPath -ForegroundColor Green

Write-Host ""

Write-Host "GitHub repository:" -ForegroundColor Yellow

gh repo view --json url --jq ".url"

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "                 RUN MACOS / XCODE" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Open the GitHub repository." -ForegroundColor White
Write-Host ""
Write-Host "Click:" -ForegroundColor White
Write-Host ""
Write-Host "  Actions" -ForegroundColor Cyan
Write-Host "     ↓" -ForegroundColor Cyan
Write-Host "  macOS Xcode Build" -ForegroundColor Cyan
Write-Host "     ↓" -ForegroundColor Cyan
Write-Host "  Run workflow" -ForegroundColor Cyan
Write-Host ""

Write-Host "GitHub will start a macOS runner." -ForegroundColor White
Write-Host ""
Write-Host "It will run:" -ForegroundColor White
Write-Host "  ✓ macOS" -ForegroundColor Green
Write-Host "  ✓ Xcode" -ForegroundColor Green
Write-Host "  ✓ Swift" -ForegroundColor Green
Write-Host "  ✓ Build" -ForegroundColor Green
Write-Host "  ✓ Tests" -ForegroundColor Green
Write-Host "  ✓ Artifact upload" -ForegroundColor Green
Write-Host ""

Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""