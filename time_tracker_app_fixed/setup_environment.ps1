# 环境变量配置脚本

# 设置Android SDK路径
$sdkPath = "$env:USERPROFILE\Android\Sdk"

# 设置系统环境变量
[System.Environment]::SetEnvironmentVariable("ANDROID_HOME", $sdkPath, "Machine")
[System.Environment]::SetEnvironmentVariable("ANDROID_SDK_ROOT", $sdkPath, "Machine")

# 更新PATH环境变量
$currentPath = [System.Environment]::GetEnvironmentVariable("PATH", "Machine")
$newPaths = @(
    "$sdkPath\platform-tools",
    "$sdkPath\cmdline-tools\bin",
    "$sdkPath\tools\bin"
)

foreach ($newPath in $newPaths) {
    if (!($currentPath -like "*$newPath*")) {
        $currentPath = "$newPath;$currentPath"
    }
}

[System.Environment]::SetEnvironmentVariable("PATH", $currentPath, "Machine")

Write-Host "环境变量配置完成！"
Write-Host "ANDROID_HOME: $sdkPath"
Write-Host "请重新启动命令提示符或PowerShell以使环境变量生效"