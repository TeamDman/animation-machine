gci -Recurse .\media\ -File -Filter "*.mp4" | Select-Object -First 1 | % { Start-Process mpv "$($_.FullName)" -Wait }
