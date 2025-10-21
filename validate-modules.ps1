# Caminho raiz do projeto
$projectPath = "C:\Users\Gusta\Desktop\aws-resilient-infra"
$modulesPath = Join-Path $projectPath "modules"

# Lista todos os módulos
$modules = Get-ChildItem -Path $modulesPath -Directory

Write-Host "`nValidando estrutura dos módulos Terraform..." -ForegroundColor Cyan

foreach ($module in $modules) {
    $moduleName = $module.Name
    $moduleDir = $module.FullName

    $mainExists = Test-Path "$moduleDir\main.tf"
    $variablesExists = Test-Path "$moduleDir\variables.tf"
    $outputsExists = Test-Path "$moduleDir\outputs.tf"

    # Verifica se há blocos indevidos no main.tf
    $mainContent = if ($mainExists) { Get-Content "$moduleDir\main.tf" -Raw } else { "" }
    $hasTerraformBlock = $mainContent -match "[\s\r\n]*terraform\s*{"
    $hasProviderBlock = $mainContent -match "[\s\r\n]*provider\s*{"

    Write-Host "`nMódulo: $moduleName" -ForegroundColor Yellow

    if (-not $mainExists) {
        Write-Host "Faltando main.tf" -ForegroundColor Red
    } else {
        Write-Host "main.tf presente" -ForegroundColor Green
    }

    if (-not $variablesExists) {
        Write-Host "Faltando variables.tf (recomendado)" -ForegroundColor DarkYellow
    } else {
        Write-Host "variables.tf presente" -ForegroundColor Green
    }

    if (-not $outputsExists) {
        Write-Host "Faltando outputs.tf (recomendado)" -ForegroundColor DarkYellow
    } else {
        Write-Host "outputs.tf presente" -ForegroundColor Green
    }

    if ($hasTerraformBlock -or $hasProviderBlock) {
        Write-Host "Bloco terraform/provider encontrado — remova para evitar execução direta!" -ForegroundColor Red
    } else {
        Write-Host "Sem blocos terraform/provider — módulo está limpo" -ForegroundColor Green
    }
}

Write-Host "`nValidação concluída!" -ForegroundColor Cyan
