# GitHub推送脚本
# 请先创建GitHub仓库，然后将下面的用户名替换为您的实际GitHub用户名

Write-Host "=== Flutter工时记录应用GitHub推送脚本 ===" -ForegroundColor Green
Write-Host ""

# 请修改这里的用户名
$githubUsername = "您的实际用户名"
$repoName = "time-tracker-app"
$repoUrl = "https://github.com/$githubUsername/$repoName.git"

Write-Host "配置的仓库URL: $repoUrl" -ForegroundColor Yellow
Write-Host ""

# 检查Git状态
try {
    git status
    Write-Host "Git状态检查完成" -ForegroundColor Green
} catch {
    Write-Host "错误：请确保Git已正确安装" -ForegroundColor Red
    exit 1
}

# 配置远程仓库
Write-Host "配置远程仓库..." -ForegroundColor Yellow
try {
    git remote remove origin 2>$null
    git remote add origin $repoUrl
    Write-Host "远程仓库配置成功" -ForegroundColor Green
} catch {
    Write-Host "远程仓库配置失败" -ForegroundColor Red
}

Write-Host ""
Write-Host "=== 手动操作步骤 ===" -ForegroundColor Cyan
Write-Host "1. 访问 https://github.com 创建名为 '$repoName' 的仓库"
Write-Host "2. 确保仓库URL为: $repoUrl"
Write-Host "3. 运行以下命令推送代码:"
Write-Host "   git branch -M main"
Write-Host "   git push -u origin main"
Write-Host ""
Write-Host "如果遇到认证问题，请使用GitHub Personal Access Token" -ForegroundColor Yellow