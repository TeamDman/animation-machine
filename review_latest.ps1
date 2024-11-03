. ./activate_env.ps1
manim -pqh animation_script.py CustomAnimation
$job_player = Start-Job { mpv .\media\videos\animation_scripy\1080p60\CustomAnimation.mp4 --loop=inf }

while ($true) {
    $response = Read-Host -Prompt "Describe the video:"
    $response | Add-Content -Path "video_description.txt"
    if ($response -eq "exit") {
        break
    }
}

Stop-Job -Id $job_player.Id
