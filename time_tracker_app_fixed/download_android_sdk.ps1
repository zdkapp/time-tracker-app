# Android SDK 手动安装脚本
# 下载Android命令行工具

# 创建Android SDK目录
$sdkDir = "$env:USERPROFILE\Android\Sdk"
if (!(Test-Path $sdkDir)) {
    New-Item -ItemType Directory -Path $sdkDir -Force
}

# 下载命令行工具
$cmdlineUrl = "https://dl.google.com/android/repository/commandlinetools-win-11076708_latest.zip"
$cmdlineZip = "$env:TEMP\commandlinetools-win.zip"

Write-Host "正在下载Android命令行工具..."

# 使用Invoke-WebRequest下载
Invoke-WebRequest -Uri $cmdlineUrl -OutFile $cmdlineZip

Write-Host "下载完成，正在解压..."

# 解压到SDK目录
Expand-Archive -Path $cmdlineZip -DestinationPath "$sdkDir\cmdline-tools" -Force

# 重命名目录结构
if (Test-Path "$sdkDir\cmdline-tools\cmdline-tools") {
    Move-Item -Path "$sdkDir\cmdline-tools\cmdline-tools\*" -Destination "$sdkDir\cmdline-tools\" -Force
    Remove-Item -Path "$sdkDir\cmdline-tools\cmdline-tools" -Force
}

Write-Host "Android命令行工具安装完成！"
Write-Host "SDK路径: $sdkDir"

# 清理临时文件
Remove-Item $cmdlineZip -Force

Write-Host "请继续执行下一步：安装必要的SDK组件"