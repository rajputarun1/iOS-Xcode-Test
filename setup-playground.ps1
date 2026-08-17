$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "====================================================" -ForegroundColor Cyan
Write-Host "     AUTOMATIC XCODE PLAYGROUND SETUP" -ForegroundColor Cyan
Write-Host "====================================================" -ForegroundColor Cyan
Write-Host ""

# ============================================================
# PROJECT PATH
# ============================================================

$ProjectPath = "C:\Dev\iOS-Xcode-Test"
$PlaygroundPath = Join-Path $ProjectPath "MyPlayground.playground"
$WorkflowPath = Join-Path $ProjectPath ".github\workflows\xcode.yml"

Write-Host "[1/7] Checking project..." -ForegroundColor Yellow

if (-not (Test-Path $ProjectPath)) {
    throw "Project directory not found: $ProjectPath"
}

Set-Location $ProjectPath

Write-Host "Project:" -ForegroundColor Green
Write-Host $ProjectPath
Write-Host ""

# ============================================================
# PLAYGROUND DIRECTORY
# ============================================================

Write-Host "[2/7] Creating Playground..." -ForegroundColor Yellow

if (-not (Test-Path $PlaygroundPath)) {

    New-Item `
        -ItemType Directory `
        -Path $PlaygroundPath `
        -Force | Out-Null

}

if (-not (Test-Path $PlaygroundPath)) {
    throw "Could not create Playground directory."
}

Write-Host "Created:" -ForegroundColor Green
Write-Host $PlaygroundPath

# ============================================================
# CONTENTS.SWIFT
# ============================================================

Write-Host ""
Write-Host "[3/7] Creating Contents.swift..." -ForegroundColor Yellow

$ContentsPath = Join-Path $PlaygroundPath "Contents.swift"

$Contents = @'
import Foundation

print("======================================")
print(" XCODE PLAYGROUND")
print("======================================")

let name = "Arun"

print("")
print("Hello, \(name)!")
print("")

let numbers = [10, 20, 30, 40, 50]

print("Numbers:")
print(numbers)

let sum = numbers.reduce(0, +)

print("")
print("Sum = \(sum)")

let squares = numbers.map {
    $0 * $0
}

print("")
print("Squares:")
print(squares)

print("")
print("Swift Playground is running on macOS.")
print("Xcode/Swift environment is working.")
print("")
print("======================================")
'@

Set-Content `
    -LiteralPath $ContentsPath `
    -Value $Contents `
    -Encoding UTF8 `
    -Force

Write-Host "Created:" -ForegroundColor Green
Write-Host $ContentsPath

# ============================================================
# PLAYGROUND METADATA
# ============================================================

Write-Host ""
Write-Host "[4/7] Creating Playground metadata..." -ForegroundColor Yellow

$MetadataPath = Join-Path $PlaygroundPath "contents.xcplayground"

$Metadata = @'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<playground version="5.0"
            target-platform="macOS"
            buildActiveScheme="true"
            importGoogle="true">
</playground>
'@

Set-Content `
    -LiteralPath $MetadataPath `
    -Value $Metadata `
    -Encoding UTF8 `
    -Force

Write-Host "Created:" -ForegroundColor Green
Write-Host $MetadataPath

# ============================================================
# WORKFLOW DIRECTORY
# ============================================================

Write-Host ""
Write-Host "[5/7] Creating GitHub Actions workflow..." -ForegroundColor Yellow

$WorkflowDirectory = Split-Path $WorkflowPath -Parent

if (-not (Test-Path $WorkflowDirectory)) {

    New-Item `
        -ItemType Directory `
        -Path $WorkflowDirectory `
        -Force | Out-Null

}

# ============================================================
# GITHUB ACTIONS WORKFLOW
# ============================================================

$Workflow = @'
name: Xcode Playground

on:

  push:
    branches:
      - main

  workflow_dispatch:

jobs:

  playground:

    runs-on: macos-latest

    steps:

      # ------------------------------------------------------
      # CHECKOUT
      # ------------------------------------------------------

      - name: Checkout repository
        uses: actions/checkout@v4

      # ------------------------------------------------------
      # MACOS
      # ------------------------------------------------------

      - name: Show macOS
        run: |
          echo "======================================"
          echo " macOS INFORMATION"
          echo "======================================"
          sw_vers

      # ------------------------------------------------------
      # XCODE
      # ------------------------------------------------------

      - name: Show Xcode
        run: |
          echo "======================================"
          echo " XCODE INFORMATION"
          echo "======================================"
          xcodebuild -version

      # ------------------------------------------------------
      # SWIFT
      # ------------------------------------------------------

      - name: Show Swift
        run: |
          echo "======================================"
          echo " SWIFT INFORMATION"
          echo "======================================"
          swift --version

      # ------------------------------------------------------
      # PLAYGROUND
      # ------------------------------------------------------

      - name: Check Playground
        run: |
          echo "======================================"
          echo " PLAYGROUND FILES"
          echo "======================================"

          find MyPlayground.playground \
            -maxdepth 2 \
            -type f \
            -print

      # ------------------------------------------------------
      # DISPLAY SOURCE
      # ------------------------------------------------------

      - name: Show Playground source
        run: |
          echo "======================================"
          echo " CONTENTS.SWIFT"
          echo "======================================"

          cat MyPlayground.playground/Contents.swift

      # ------------------------------------------------------
      # EXECUTE PLAYGROUND
      # ------------------------------------------------------

      - name: Execute Playground
        run: |

          mkdir -p output

          echo "======================================"
          echo " PLAYGROUND OUTPUT"
          echo "======================================"

          swift \
            MyPlayground.playground/Contents.swift \
            2>&1 | tee output/playground-output.txt

      # ------------------------------------------------------
      # SAVE ENVIRONMENT
      # ------------------------------------------------------

      - name: Save environment information
        run: |

          mkdir -p output

          sw_vers \
            > output/macos.txt

          xcodebuild -version \
            > output/xcode.txt

          swift --version \
            > output/swift.txt

      # ------------------------------------------------------
      # COPY PLAYGROUND
      # ------------------------------------------------------

      - name: Copy Playground
        run: |

          cp -R \
            MyPlayground.playground \
            output/MyPlayground.playground

      # ------------------------------------------------------
      # UPLOAD
      # ------------------------------------------------------

      - name: Upload Playground artifacts
        uses: actions/upload-artifact@v4

        with:

          name: MyPlayground-macOS

          path: output/
'@

Set-Content `
    -LiteralPath $WorkflowPath `
    -Value $Workflow `
    -Encoding UTF8 `
    -Force

Write-Host "Created workflow:" -ForegroundColor Green
Write-Host $WorkflowPath

# ============================================================
# GIT STATUS
# ============================================================

Write-Host ""
Write-Host "[6/7] Committing changes..." -ForegroundColor Yellow

git add .

$Status = git status --porcelain

if ($Status) {

    git commit `
        -m "Add Xcode Playground automation"

}
else {

    Write-Host "No changes detected." -ForegroundColor Yellow

}

# ============================================================
# PUSH
# ============================================================

Write-Host ""
Write-Host "[7/7] Pushing to GitHub..." -ForegroundColor Yellow

$Remote = git remote get-url origin

if (-not $Remote) {
    throw "GitHub origin remote is missing."
}

Write-Host ""
Write-Host "Remote:" -ForegroundColor Green
Write-Host $Remote

Write-Host ""
Write-Host "Pushing main..." -ForegroundColor Yellow

git branch -M main
git push origin main

# ============================================================
# DONE
# ============================================================

Write-Host ""
Write-Host "====================================================" -ForegroundColor Green
Write-Host "             AUTOMATION COMPLETE" -ForegroundColor Green
Write-Host "====================================================" -ForegroundColor Green
Write-Host ""

Write-Host "Playground:" -ForegroundColor Yellow
Write-Host $PlaygroundPath

Write-Host ""

Write-Host "GitHub workflow:" -ForegroundColor Yellow
Write-Host ".github\workflows\xcode.yml"

Write-Host ""
Write-Host "GitHub will now automatically:" -ForegroundColor White

Write-Host "  [1] Start a macOS runner" -ForegroundColor Green
Write-Host "  [2] Load Xcode" -ForegroundColor Green
Write-Host "  [3] Load Swift" -ForegroundColor Green
Write-Host "  [4] Load your Playground" -ForegroundColor Green
Write-Host "  [5] Execute Contents.swift" -ForegroundColor Green
Write-Host "  [6] Save the output" -ForegroundColor Green
Write-Host "  [7] Upload the Playground artifact" -ForegroundColor Green

Write-Host ""
Write-Host "====================================================" -ForegroundColor Cyan
Write-Host ""
