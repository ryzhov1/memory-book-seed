# Запуск Chrome для архивного поиска (pamyat-naroda и др.) под chrome-devtools MCP.
#
# pamyat-naroda не пропускает капчу в Chrome, который запускает сам MCP
# (пометка «управляется автоматикой»). Поэтому Chrome запускаем мы, а MCP
# подключается к нему по порту отладки:
#   claude mcp add --scope local chrome-devtools -- npx -y chrome-devtools-mcp@latest --browserUrl=http://127.0.0.1:9222
#
# Порядок: закрыть Claude Code → запустить этот скрипт → в открывшемся окне
# открыть pamyat-naroda.ru, решить капчу, сделать любой поиск, окно не закрывать →
# запустить claude.
#
# Отдельный профиль (--user-data-dir) обязателен: Chrome не даёт отладку на
# основном профиле. Обычные вкладки и пароли не затрагиваются.

param(
    [int]$Port = 9222,
    [string]$UserDataDir = "C:\chrome-pamyat"
)

$candidates = @(
    "$env:ProgramFiles\Google\Chrome\Application\chrome.exe",
    "${env:ProgramFiles(x86)}\Google\Chrome\Application\chrome.exe",
    "$env:LOCALAPPDATA\Google\Chrome\Application\chrome.exe"
)
$chrome = $candidates | Where-Object { Test-Path $_ } | Select-Object -First 1
if (-not $chrome) {
    Write-Error "chrome.exe не найден. Укажите путь вручную в скрипте."
    exit 1
}

try {
    Invoke-WebRequest -UseBasicParsing "http://127.0.0.1:$Port/json/version" -TimeoutSec 2 | Out-Null
    Write-Host "Chrome с портом $Port уже запущен — можно запускать claude."
    exit 0
} catch {}

Start-Process -FilePath $chrome -ArgumentList @(
    "--remote-debugging-port=$Port",
    "--user-data-dir=$UserDataDir",
    "https://pamyat-naroda.ru/"
)
Write-Host "Chrome запущен (порт $Port, профиль $UserDataDir)."
Write-Host "Решите капчу на pamyat-naroda, сделайте любой поиск, окно не закрывайте, затем запустите claude."
