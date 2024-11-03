[CmdletBinding()]
param(
    [switch]$wipe
)

# Function to copy current directory to clipboard
function Copy-CurrentDirectory {
    $currentDir = (Get-Location).Path
    $currentDir | Set-Clipboard
    Write-Host "Current directory path copied to clipboard: $currentDir" -ForegroundColor Green
}

# Function to execute a command with redirection and handle output
function Execute-Command {
    param (
        [string]$Command,
        [string[]]$Arguments
    )

    # Execute the command, capturing both stdout and stderr
    # Redirect stderr to stdout using 2>&1
    $output = & $Command @Arguments 2>&1

    # Capture the exit code
    $exitCode = $LASTEXITCODE

    return @{
        Output   = $output
        ExitCode = $exitCode
    }
}

# Handle the -wipe parameter
if ($wipe) {
    if (Test-Path -Path "video_description.txt") {
        Remove-Item -Path "video_description.txt" -Force
        Write-Host "Previous video descriptions wiped." -ForegroundColor Yellow
    } else {
        Write-Host "No existing video descriptions to wipe." -ForegroundColor Cyan
    }
}

# Copy current directory to clipboard
Copy-CurrentDirectory

# Activate the environment if necessary
# . ./activate_env.ps1

# Define the path to the Manim script
$scriptPath = "animation_script.py"  # Ensure this path is correct

# Execute the Manim command and capture outputs
$manimResult = Execute-Command -Command "manim" -Arguments @("-pqh", $scriptPath, "CustomAnimation")

# Check if Manim execution was successful
if ($manimResult.ExitCode -ne 0) {
    Write-Host "An error occurred while rendering the animation:" -ForegroundColor Red
    # Display the output with preserved line breaks
    Write-Host $manimResult.Output -ForegroundColor Red

    # Copy combined output to clipboard
    $manimResult.Output | Set-Clipboard
    Write-Host "stdout + stderr copied to clipboard!" -ForegroundColor Yellow

    exit 1
}

# If successful, copy output to clipboard
Write-Host "Animation rendered successfully." -ForegroundColor Green
# Display the output with preserved line breaks
Write-Host $manimResult.Output -ForegroundColor Green
$manimResult.Output | Set-Clipboard
Write-Host "stdout + stderr copied to clipboard!" -ForegroundColor Green

# Define the correct video path
$videoPath = ".\media\videos\animation_script\1080p60\CustomAnimation.mp4"

# Check if the video file exists before attempting to play
if (Test-Path -Path $videoPath) {
    # Start playing the video in a background job
    $job_player = Start-Job -ScriptBlock { 
        mpv "$using:videoPath" --loop=inf 
    }
    Write-Host "Video is playing in the background. You can describe it now." -ForegroundColor Cyan
} else {
    Write-Host "Video file not found at path: $videoPath" -ForegroundColor Red
    exit 1
}

# Prompt the user for descriptions
while ($true) {
    $response = Read-Host -Prompt "Describe the video (type 'exit' to finish)"
    if ($response -eq "exit") {
        break
    }
    if ($response -eq "publish") {
        Write-Host "❯ git diff" -ForegroundColor Yellow
        git diff
        $proceed = "proceed`nabort" | fzf --height 4
        if ($proceed -eq "proceed") {
            Write-Host "❯ git add ." -ForegroundColor Yellow
            git add .
            Write-Host "❯ git commit -m 'Add video description'" -ForegroundColor Yellow
            git commit -m "Add video description"
            Write-Host "❯ git push" -ForegroundColor Yellow
            git push
            Write-Host "Video description published." -ForegroundColor Green

            # bump tag semver
            $tag = git describe --tags --abbrev=0
            $tag = $tag -replace 'v', ''
            $tag = $tag -split '\.'
            $tag[2] = [int]$tag[2] + 1
            $tag = "v$($tag[0]).$($tag[1]).$($tag[2])"
            Write-Host "❯ git tag $tag" -ForegroundColor Yellow
            git tag $tag
            Write-Host "❯ git push origin $tag" -ForegroundColor Yellow
            git push origin $tag
            Write-Host "Tag $tag pushed." -ForegroundColor Green
        }
    }
    $response | Add-Content -Path "video_description.txt"
}

# Stop the video playing job
if ($job_player) {
    Stop-Job -Job $job_player
    Remove-Job -Job $job_player
    Write-Host "Video playback stopped." -ForegroundColor Yellow
}
