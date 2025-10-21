# Caminho raiz do projeto
$projectPath = "C:\Users\Gusta\Desktop\aws-resilient-infra"
$modulesPath = Join-Path $projectPath "modules"

# Lista todos os módulos
$modules = Get-ChildItem -Path $modulesPath -Directory

Write-Host "`nRemovendo blocos terraform/provider dos módulos..." -ForegroundColor Cyan

foreach ($module in $modules) {
    $moduleName = $module.Name
    $mainPath = Join-Path $module.FullName "main.tf"

    if (Test-Path $mainPath) {
        $content = Get-Content $mainPath -Raw

        # Remove blocos terraform { ... }
        $content = $content -replace '(?s)terraform\s*{.*?}', ''

        # Remove blocos provider { ... }
        $content = $content -replace '(?s)provider\s*{.*?}', ''

        # Salva o conteúdo limpo
        Set-Content -Path $mainPath -Value $content

        Write-Host "Limpo main.tf de $moduleName" -ForegroundColor Green
    } else {
        Write-Host "$moduleName não possui main.tf" -ForegroundColor DarkYellow
    }
}

Write-Host "`nLimpeza concluida!" -ForegroundColor Cyan
Write-Host "Todos os blocos terraform/provider foram removidos dos módulos." -ForegroundColor Cyan  