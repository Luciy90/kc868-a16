# Скрипт для исправления проблемы с Git в ESP-IDF сборке
$buildDir = ".esphome\build\kc868-a16-a"

# Получаем текущий HEAD коммит хэш
try {
    $commitHash = git rev-parse HEAD 2>$null
    if (-not $commitHash) {
        $commitHash = "4fc4b28"  # fallback hash
    }
} catch {
    $commitHash = "4fc4b28"  # fallback hash
}

# Создаем Git файлы для основной сборки
$gitDirs = @(
    "$buildDir\.pioenvs\kc868-a16-a\CMakeFiles\git-data",
    "$buildDir\.pioenvs\kc868-a16-a\bootloader\CMakeFiles\git-data"
)

# Дополнительные директории которые могут потребоваться
$additionalGitDirs = @(
    "$buildDir\.pioenvs\kc868-a16-a\bootloader\CMakeFiles",
    "$buildDir\.pioenvs\kc868-a16-a\CMakeFiles"
)

# Создаем основные директории с Git файлами
foreach ($dir in $gitDirs) {
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Force -Path $dir | Out-Null
    }
    Set-Content -Path "$dir\head-ref" -Value $commitHash
    Set-Content -Path "$dir\HEAD" -Value "ref: refs/heads/main"
    Write-Host "Created Git files in $dir"
}

# Создаем дополнительные директории если они не существуют
foreach ($dir in $additionalGitDirs) {
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Force -Path $dir | Out-Null
    }
}

# Также создаем файл grabRef.cmake если он отсутствует
$grabRefPath = "$buildDir\.pioenvs\kc868-a16-a\CMakeFiles\git-data\grabRef.cmake"
if (-not (Test-Path $grabRefPath)) {
    $grabRefContent = @'
# This is a generated file from ESP-IDF build system

# Find git executable
find_package(Git QUIET)

# Function to get git head revision
function(get_git_head_revision)
    if(NOT GIT_FOUND)
        return()
    endif()

    execute_process(
        COMMAND ${GIT_EXECUTABLE} rev-parse --short HEAD
        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
        OUTPUT_VARIABLE GIT_HEAD_SHORT
        OUTPUT_STRIP_TRAILING_WHITESPACE
        RESULT_VARIABLE GIT_RESULT
    )

    if(GIT_RESULT EQUAL 0)
        set(HEAD_HASH ${GIT_HEAD_SHORT} PARENT_SCOPE)
    endif()
endfunction()

# Get git head revision
get_git_head_revision()

# Write head hash to file
if(DEFINED HEAD_HASH)
    file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/CMakeFiles/git-data/head-ref ${HEAD_HASH})
endif()
'@
    Set-Content -Path $grabRefPath -Value $grabRefContent
    Write-Host "Created grabRef.cmake in $grabRefPath"
}

Write-Host "Git files created successfully!"