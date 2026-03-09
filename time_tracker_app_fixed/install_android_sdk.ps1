# Android SDK 组件安装脚本

# 设置SDK路径
$sdkPath = "$env:USERPROFILE\Android\Sdk"
$sdkManager = "$sdkPath\cmdline-tools\bin\sdkmanager.bat"

# 检查sdkmanager是否存在
if (!(Test-Path $sdkManager)) {
    Write-Host "错误：sdkmanager.bat 未找到，请确保命令行工具已正确安装"
    Write-Host "请检查路径: $sdkManager"
    exit 1
}

Write-Host "开始安装Android SDK组件..."

# 接受所有许可证
& $sdkManager "--licenses"

# 安装必要的SDK包
$packages = @(
    "platform-tools",
    "build-tools;34.0.0",
    "platforms;android-34",
    "platforms;android-33",
    "emulator",
    "patcher;v4"
)

foreach ($package in $packages) {
    Write-Host "正在安装: $package"
    & $sdkManager $package
}

Write-Host "Android SDK组件安装完成！"
Write-Host "SDK路径: $sdkPath"