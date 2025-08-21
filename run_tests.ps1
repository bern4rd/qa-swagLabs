<#
.SYNOPSIS
    Executa testes do Robot Framework sequencialmente para Android e iOS, baseado em tags

.DESCRIPTION
    Este script lê um arquivo de tags e executa os testes uma tag por vez para evitar conflitos de recurso
    - No macOS (requer PS7+): Executa os testes para Android e iOS
    - No Windows: Executa apenas os testes para Android
#>

Write-Host "Iniciando o servidor Appium em um job de segundo plano"
$appiumJob = Start-Job -ScriptBlock { 
    appium --base-path=/wd/hub --allow-cors -p 4723 *> $null
}
Write-Host "Job do Appium iniciado com ID $($appiumJob.Id). Aguardando inicializacao..."
Start-Sleep -Seconds 5 

$maxRetries = 5
$retryDelaySeconds = 3
$appiumPort = 4723
$appiumReady = $false

for ($i = 1; $i -le $maxRetries; $i++) {
    Write-Host "Tentativa $i de ${maxRetries}: Verificando se o Appium esta rodando na porta $appiumPort..."
    try {
        $connection = Test-NetConnection -ComputerName localhost -Port $appiumPort -ErrorAction Stop
        if ($connection.TcpTestSucceeded) {
            Write-Host "Appium esta pronto e aceitando conexoes." -ForegroundColor Green
            $appiumReady = $true
            break
        }
    }
    catch {
        Write-Host "Appium ainda nao esta pronto. Aguardando $retryDelaySeconds segundos..."
        Start-Sleep -Seconds $retryDelaySeconds
    }
}

if (-not $appiumReady) {
    Write-Error "Nao foi possivel conectar ao Appium na porta $appiumPort apos $maxRetries tentativas."
    throw "Falha ao iniciar o Appium."
}

try {
    $testsRootFolder = "./tests" 
    $tagListFile = Join-Path $PSScriptRoot "resources/devdata/test_tags.txt"

    Write-Host "Pasta do projeto: $PSScriptRoot" -ForegroundColor Gray
    Write-Host "Pasta raiz dos testes: $testsRootFolder" -ForegroundColor Gray

    $IsRunningOnMac = $false
    if ($PSVersionTable.PSEdition -eq 'Core' -and $IsMacOs) {
        $IsRunningOnMac = $true
    }
    $OsType = if ($IsWindows -or $env:OS -eq "Windows_NT") { "Windows" } elseif ($IsMacOS) { "macOS" } elseif ($IsLinux) { "Linux" } else { "Unknown" }
    Write-Host "Sistema Operacional Detectado: $OsType"

    if (-not (Test-Path $tagListFile)) {
        Write-Error "Arquivo de tags nao encontrado em: $tagListFile"
        exit 1
    }

    $tags = Get-Content $tagListFile
    if ($tags.Count -eq 0) {
        Write-Host "Nenhuma tag encontrada para execucao no arquivo '$tagListFile'" -ForegroundColor Yellow
    } else {
        
        $tags | ForEach-Object {
            $tagToRun +="OR$_"
        }

        $tagToRun = $tagToRun.TrimStart('OR')

        # --- Execucao Android ---
        Write-Host "Limpando processos UiAutomator2 residuais"
        adb -s emulator-5554 shell am force-stop io.appium.uiautomator2.server.test
        adb -s emulator-5554 shell am force-stop io.appium.uiautomator2.server
        Start-Sleep -Seconds 2

        $variables = "-v PLATFORM:Android"      # Variáveis utilizadas na execução (Android): PLATFORM
        $log_level = "FAIL"                     # Nível de log para a execução (FAIL, ERROR, INFO, DEBUG, TRACE)
        $listeners = "RetryFailed:1"            # Listeners utilizados na execução - (RetryFailed:1) significa que o teste será reexecutado uma vez em caso de falha
        $outputPathAndroid = "logs/Android/"    # Caminho para os logs de saída do Android

        $parameters = "$variables -i $tagToRun -L $log_level --listener $listeners -d $outputPathAndroid $testsRootFolder"

        Set-Location $PSScriptRoot

        #write-host "pipenv run robot $parameters"
        pipenv run robot $parameters

        Write-Host "=== Concluido: testes concluidos no Android ===" -ForegroundColor Gray

        # --- Execucao iOS (se estiver no macOS) ---
        if ($IsRunningOnMac) {
            Write-Host "Aguardando antes do proximo teste de plataforma" -ForegroundColor Gray

            $outputPathiOS = "logs/iOS"
            
            #Limpa processos residuais do xuitest antes de cada teste
            Write-Host "Limpando processos xuitest residuais"
            xcrun simctl shutdown all

            Set-Location $PSScriptRoot
            pipenv run robot $tagToRun --variable PLATFORM:iOS -L INFO --outputdir $outputPathiOS $testsRootFolder
            Write-Host "=== Concluido: testes concluidos no iOS ===" -ForegroundColor Gray
        }
    }
}
finally {
    # Garante que o servidor Appium seja sempre encerrado
    Write-Host "Encerrando o servidor Appium" -ForegroundColor Yellow
    Stop-Job -Job $appiumJob
    
    Write-Host "Coletando logs do job do Appium"
    Receive-Job -Job $appiumJob
    
    Remove-Job -Job $appiumJob
    Write-Host "Job do Appium removido"
}

Write-Host "Execucao de testes finalizada" -ForegroundColor Green