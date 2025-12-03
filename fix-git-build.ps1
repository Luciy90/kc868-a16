# Скрипт для исправления проблемы с Git в ESP-IDF сборке
$buildDir = ".esphome\build\kc868-a16-a"

# Создаем Git файлы для основной сборки
$gitDirs = @(
    "$buildDir\.pioenvs\kc868-a16-a\CMakeFiles\git-data",
    "$buildDir\.pioenvs\kc868-a16-a\bootloader\CMakeFiles\git-data"
)

foreach ($dir in $gitDirs) {
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Force -Path $dir | Out-Null
    }
    Set-Content -Path "$dir\head-ref" -Value "refs/heads/main"
    Set-Content -Path "$dir\HEAD" -Value "ref: refs/heads/main"
    Write-Host "Created Git files in $dir"
}

Write-Host "Git files created successfully!"



