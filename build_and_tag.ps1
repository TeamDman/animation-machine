# build_and_tag.ps1

param (
    [Parameter(Mandatory=$true)]
    [string]$Version,
    [Parameter(Mandatory=$false)]
    [string]$Description = ""
)

# Build the animation using Manim
# Adjust the command as needed
manim -pqh animation_script.py CustomAnimation

# Get the latest commit hash
$commitHash = git rev-parse --short HEAD

# Define the video output path
$videoOutputDir = "videos"
if (-not (Test-Path -Path $videoOutputDir)) {
    New-Item -ItemType Directory -Path $videoOutputDir | Out-Null
}

# Copy the generated video to the videos directory with the version name
$sourceVideoPath = "media/videos/animation_script/1080p60/CustomAnimation.mp4"
$destinationVideoPath = "$videoOutputDir\$Version" + "_CustomAnimation.mp4"
Copy-Item -Path $sourceVideoPath -Destination $destinationVideoPath -Force

# Add changes to Git
git add .
git commit -m "$Description"

# Tag the new version
git tag -a $Version -m "$Description"

# Update CHANGELOG.md
$changeLogEntry = @"
## [$Version] - $(Get-Date -Format "yyyy-MM-dd")

- **Description:** $Description
- **Video:** [$destinationVideoPath]($destinationVideoPath)
"@

Add-Content -Path "CHANGELOG.md" -Value $changeLogEntry

# Commit the CHANGELOG.md
git add CHANGELOG.md
git commit --amend --no-edit

Write-Host "Build and tagging complete for version $Version"
