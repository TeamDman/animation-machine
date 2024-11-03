$files_to_include = Get-Content .\file_selection.txt

$prompt = "File contents:"
foreach ($file in $files_to_include) {
    $prompt += "`n$file`n"
    $prompt += Get-Content -Path $file -Raw
    $prompt += "`n"
}
$prompt | Set-Clipboard
Write-Host "Copied prompt to clipboard! Contained $($files_to_include.Count) files."