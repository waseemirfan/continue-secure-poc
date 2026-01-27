# Script to build Core module and Binary for IntelliJ plugin testing
# Use this when making changes to Core and want to quickly test in IntelliJ
# 
# Build chain: Packages (Layer 1,2,3) → Core → Binary → IntelliJ ready
# Time: ~5-10 minutes depending on machine

Write-Host "`n=== Core Module Setup (Minimal) ===" -ForegroundColor Cyan

# Check Node.js
$node = (get-command node -ErrorAction SilentlyContinue)
if ($null -eq $node) {
    Write-Host "❌ Node.js not found. Please install Node.js first." -ForegroundColor Red
    exit 1
}
Write-Host "✅ Found Node.js $(node -v)" -ForegroundColor Green

# Check .nvmrc version match
if (Test-Path ".nvmrc") {
    $requiredVersion = (Get-Content ".nvmrc").TrimStart('v')
    $currentVersion = (node -v).TrimStart('v')
    
    if ($requiredVersion -ne $currentVersion) {
        Write-Host "⚠️  Node version mismatch: required $requiredVersion, got $currentVersion" -ForegroundColor Yellow
    }
}

Write-Host "`n📦 Step 1: Install root dependencies..." -ForegroundColor Cyan
npm install
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Root install failed" -ForegroundColor Red
    exit 1
}
Write-Host "✅ Root dependencies installed" -ForegroundColor Green

Write-Host "`n📦 Step 2: Build required packages in order..." -ForegroundColor Cyan
Write-Host "   → Building: config-types, terminal-security" -ForegroundColor Yellow

Push-Location packages/config-types
npm install
npm run build
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ config-types build failed" -ForegroundColor Red
    exit 1
}
Pop-Location
Write-Host "✅ config-types built" -ForegroundColor Green

Push-Location packages/terminal-security
npm install
npm run build
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ terminal-security build failed" -ForegroundColor Red
    exit 1
}
Pop-Location
Write-Host "✅ terminal-security built" -ForegroundColor Green

Write-Host "   → Building: fetch, config-yaml, llm-info" -ForegroundColor Yellow

Push-Location packages/fetch
npm install
npm run build
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ fetch build failed" -ForegroundColor Red
    exit 1
}
Pop-Location
Write-Host "✅ fetch built" -ForegroundColor Green

Push-Location packages/config-yaml
npm install
npm run build
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ config-yaml build failed" -ForegroundColor Red
    exit 1
}
Pop-Location
Write-Host "✅ config-yaml built" -ForegroundColor Green

Push-Location packages/llm-info
npm install
npm run build
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ llm-info build failed" -ForegroundColor Red
    exit 1
}
Pop-Location
Write-Host "✅ llm-info built" -ForegroundColor Green

Write-Host "   → Building: openai-adapters" -ForegroundColor Yellow

Push-Location packages/openai-adapters
npm install
npm run build
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ openai-adapters build failed" -ForegroundColor Red
    exit 1
}
Pop-Location
Write-Host "✅ openai-adapters built" -ForegroundColor Green

Write-Host "`n📦 Step 3: Install and build Core module..." -ForegroundColor Cyan

Push-Location core
npm install
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Core npm install failed" -ForegroundColor Red
    exit 1
}
Write-Host "✅ Core dependencies installed" -ForegroundColor Green

npm run build
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Core build failed" -ForegroundColor Red
    exit 1
}
Write-Host "✅ Core built successfully" -ForegroundColor Green

npm link
Write-Host "✅ Core linked for local usage" -ForegroundColor Green

Pop-Location

Write-Host "`n📦 Step 4: Build Binary (required for IntelliJ plugin)..." -ForegroundColor Cyan

Push-Location binary
npm install
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Binary npm install failed" -ForegroundColor Red
    exit 1
}
Write-Host "✅ Binary dependencies installed" -ForegroundColor Green

npm run build
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Binary build failed" -ForegroundColor Red
    exit 1
}
Write-Host "✅ Binary built successfully" -ForegroundColor Green

Pop-Location

Write-Host "`n🎉 === Setup complete for IntelliJ testing! ===" -ForegroundColor Green
Write-Host "Core module: $(Get-Location)\core\dist" -ForegroundColor Cyan
Write-Host "Binary (for IntelliJ): $(Get-Location)\binary\bin" -ForegroundColor Cyan
Write-Host "`nYou can now build and test the IntelliJ plugin" -ForegroundColor Green
