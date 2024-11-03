# version_copy.ps1

# Define the versions directory
$versionsDir = Join-Path -Path (Get-Location) -ChildPath 'versions'

# Ensure the versions directory exists
if (-not (Test-Path -Path $versionsDir)) {
    New-Item -ItemType Directory -Path $versionsDir | Out-Null
}

# Get the list of existing version folders and determine the next version number
$existingVersions = Get-ChildItem -Path $versionsDir -Directory |
    Where-Object { $_.Name -match '^\d+$' } |
    Sort-Object { [int]$_.Name }

if ($existingVersions) {
    $lastVersion = [int]$existingVersions[-1].Name
    $nextVersion = $lastVersion + 1
} else {
    $nextVersion = 1
}

# Format the version number with leading zeros (e.g., '00001')
$versionFolderName = '{0:D5}' -f $nextVersion
$versionFolderPath = Join-Path -Path $versionsDir -ChildPath $versionFolderName

# Create the new version folder
New-Item -ItemType Directory -Path $versionFolderPath | Out-Null

# Read the selected files from 'file_selection.txt'
if (-not (Test-Path -Path 'file_selection.txt')) {
    Write-Host "Error: 'file_selection.txt' not found. Please run 'select_files.ps1' first."
    exit
}

$selectedFiles = Get-Content -Path 'file_selection.txt'

# Copy each selected file to the new version folder
foreach ($file in $selectedFiles) {
    $sourcePath = (Get-Item -Path $file).FullName
    $destinationPath = Join-Path -Path $versionFolderPath -ChildPath (Split-Path -Path $file -Leaf)
    Copy-Item -Path $sourcePath -Destination $destinationPath -Force
}

Write-Host "Selected files have been copied to version '$versionFolderName'"
