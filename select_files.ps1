# Use fzf to select files and save the selection to a variable
$selectedFiles = fzf --multi --height '99%'

# Check if any files were selected
if ([string]::IsNullOrEmpty($selectedFiles)) {
    Write-Host "No files selected."
    exit
}

# Save the selected file paths to 'file_selection.txt'
$selectedFiles | Out-File -FilePath 'file_selection.txt' -Encoding UTF8

Write-Host "Selected files have been saved to 'file_selection.txt'"
