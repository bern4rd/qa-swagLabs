<#
.SYNOPSIS
    Executa testes do Robot Framework sequencialmente para Android e iOS, baseado em tags

.DESCRIPTION
    Este script lê um arquivo de tags e executa os testes uma tag por vez para evitar conflitos de recurso
    - No macOS (requer PS7+): Executa os testes para Android e iOS
    - No Windows: Executa apenas os testes para Android
#>

function log_info {
    param([string]$message)
    Write-Host "[INFO] $message" -ForegroundColor Blue
}

function log_success {
    param([string]$message)
    Write-Host "[SUCCESS] $message" -ForegroundColor Green
}

function log_warning {
    param([string]$message)
    Write-Host "[WARNING] $message" -ForegroundColor Yellow
}

function log_error {
    param([string]$message)
    Write-Host "[ERROR] $message" -ForegroundColor Red
}

function Test-VersionsCompatible {
    param(
        [string]$version1,  # versao atual (ex: 3.9.13)
        [string]$version2   # especificacao desejada (ex: ^3.12 ou 3.9.13)
    )
    
    # Se a especificacao e exata, comparar diretamente
    if ($version2 -match '^[0-9]+\.[0-9]+\.[0-9]+$') {
        return $version1 -eq $version2
    }
    
    # Se a especificacao e tipo Poetry (^3.12, >=3.12, etc.)
    if ($version2 -match '^[^0-9]*([0-9]+\.[0-9]+)') {
        $base_version = $matches[1]
        $current_base = ($version1 -split '\.')[0..1] -join '.'
        
        # Para ^3.12, aceitar qualquer 3.12.x
        if ($version2 -match '^\^') {
            return $current_base -eq $base_version
        }
        
        # Para outras especificacoes, ser mais permissivo
        return $current_base -eq $base_version
    }
    
    # Fallback: se nao conseguiu interpretar, considerar incompativel
    return $false
}

function Clear-OldVirtualEnvs {
    log_info "Verificando ambientes virtuais existentes..."
    
    # Verificar se existe um ambiente virtual ativo diferente do atual
    if ($env:VIRTUAL_ENV -and $env:VIRTUAL_ENV -ne "$script:PROJECT_ROOT\.venv") {
        log_warning "Ambiente virtual ativo detectado: $env:VIRTUAL_ENV"
        log_info "Desativando ambiente virtual atual para criar novo..."
        # No PowerShell, nao ha comando deactivate direto, o Poetry gerencia isso
    }
    
    # Listar ambientes Poetry existentes
    if (Get-Command poetry -ErrorAction SilentlyContinue) {
        try {
            $existing_envs = @()
            try {
                $existing_envs = poetry env list 2>$null | Where-Object { $_ -notlike "*Activated*" }
                if ($LASTEXITCODE -ne 0) { $existing_envs = @() }
            } catch {
                $existing_envs = @()
            }
            if ($existing_envs) {
                log_warning "Encontrados ambientes virtuais Poetry existentes:"
                $existing_envs | ForEach-Object { Write-Host $_ }
                
                log_info "Removendo ambientes virtuais antigos..."
                # Remover todos os ambientes Poetry
                try {
                    poetry env remove --all 2>$null
                } catch {
                    # Ignorar erros
                }
            }
        } catch {
            # Ignorar erros de listagem
        }
    }
    
    # Remover diretorio .venv se existir mas estiver corrompido
    if (Test-Path ".venv") {
        log_info "Verificando integridade do ambiente virtual existente..."
        $env_corrupted = $false
        try {
            poetry env info | Out-Null
            if ($LASTEXITCODE -ne 0) { $env_corrupted = $true }
        } catch {
            $env_corrupted = $true
        }
        
        if (-not (Test-Path ".venv\pyvenv.cfg") -or $env_corrupted) {
            log_warning "Ambiente virtual corrompido detectado. Removendo..."
            Remove-Item ".venv" -Recurse -Force -ErrorAction SilentlyContinue
            log_success "Ambiente virtual corrompido removido"
        }
    }
}

function Get-ExactPythonVersion {
    # Primeiro tentar extrair do pyproject.toml
    if (Test-Path "pyproject.toml") {
        $content = Get-Content "pyproject.toml" -Raw
        if ($content -match 'python = "([^"]*)"') {
            $pyproject_version = $matches[1]
            if ($pyproject_version -match '^[0-9]+\.[0-9]+\.[0-9]+$') {
                # Se e uma versao exata (ex: 3.9.13)
                return $pyproject_version
            } elseif ($pyproject_version -match '^[^0-9]*([0-9]+\.[0-9]+)') {
                # Se e uma especificacao Poetry (ex: ^3.12, >=3.12,<4.0)
                $base_version = $matches[1]
                # Para pyenv, usar a versao mais recente instalada dessa serie
                if (Get-Command pyenv -ErrorAction SilentlyContinue) {
                    $latest_installed = ""
                    try {
                        $latest_installed = pyenv versions --bare 2>$null | Where-Object { $_ -match "^$base_version\." } | Sort-Object { [version]$_ } | Select-Object -Last 1
                        if ($LASTEXITCODE -ne 0) { $latest_installed = "" }
                    } catch {
                        $latest_installed = ""
                    }
                    if ($latest_installed) {
                        return $latest_installed
                    } else {
                        # Se nao tem nenhuma instalada, sugerir a mais recente conhecida
                        $patch_version = ($script:PYTHON_DEFAULT_VERSION -split '\.')[2]  # Usar patch version padrao
                        return "$base_version.$patch_version"
                    }
                }
            }
        }
    }
    
    # Fallback para .python-version se ainda existir
    if (Test-Path ".python-version") {
        return (Get-Content ".python-version").Trim()
    } else {
        return ""
    }
}

function Test-InProjectVirtualEnv {
    # Verificar se esta no ambiente Poetry do projeto especificamente
    if ((Test-Path ".venv") -and (Get-Command poetry -ErrorAction SilentlyContinue)) {
        try {
            # Obter path do ambiente ativo
            $current_env = poetry env info --path 2>$null
            $project_env = Resolve-Path ".venv" -ErrorAction SilentlyContinue
            
            # Verificar se sao o mesmo caminho
            if ($current_env -and $project_env -and ($current_env -eq $project_env.Path)) {
                # Verificar se ambiente esta realmente funcional
                if (Test-Path ".venv\pyvenv.cfg") {
                    return $true
                }
            }
        } catch {
            return $false
        }
    }
    
    return $false
}

function Initialize-VirtualEnvironment {
    log_info "Verificando ambiente virtual..."
    
    # Limpar ambientes virtuais antigos/corrompidos primeiro
    Clear-OldVirtualEnvs
    
    # Verificar se ja esta no ambiente virtual especifico do projeto
    if (Test-InProjectVirtualEnv) {
        log_success "Ja esta no ambiente virtual do projeto"
        
        # Verificar se a versao Python do ambiente virtual coincide com pyproject.toml
        log_info "Verificando compatibilidade da versao Python do ambiente virtual..."
        $required_version = ""
        if (Test-Path "pyproject.toml") {
            $content = Get-Content "pyproject.toml" -Raw
            if ($content -match 'python = "([^"]+)"') {
                $required_version = $matches[1]
            }
        }
        
        if ($required_version) {
            try {
                $env_info = poetry env info 2>$null
                $env_python_version = ($env_info | Select-String "Python:" | ForEach-Object { ($_ -split ':')[1].Trim() }) | Select-Object -First 1
                
                if ($env_python_version -and -not (Test-VersionsCompatible $env_python_version $required_version)) {
                    log_warning "(WARNING) Ambiente virtual usa Python $env_python_version, mas pyproject.toml exige $required_version"
                    log_info "(REFRESH) Recriando ambiente virtual com Python compativel..."
                    
                    # Remover ambiente virtual atual
                    try { 
                        poetry env remove --all 2>$null 
                    } catch { 
                        # Ignorar erros na remoção do ambiente virtual
                    }
                    Remove-Item ".venv" -Recurse -Force -ErrorAction SilentlyContinue
                    
                    # Remover poetry.lock para forcar regeneracao com nova versao Python
                    if (Test-Path "poetry.lock") {
                        log_info "(LOCK) Removendo poetry.lock para regeneracao com versao Python compativel..."
                        Remove-Item "poetry.lock" -Force
                    }
                    
                    # Configurar pyenv para usar a versao correta se disponivel
                    $target_version = Get-ExactPythonVersion
                    if ((Get-Command pyenv -ErrorAction SilentlyContinue) -and $target_version) {
                        try {
                            $available_versions = @()
                            try {
                                $available_versions = pyenv versions --bare 2>$null
                                if ($LASTEXITCODE -ne 0) { $available_versions = @() }
                            } catch {
                                $available_versions = @()
                            }
                            if ($available_versions -contains $target_version) {
                                $env:PYENV_VERSION = $target_version
                                Set-Content ".python-version" $target_version
                                log_info "(PYTHON) Configurado pyenv para Python $target_version"
                            }
                        } catch {
                            # Ignorar erros do pyenv
                        }
                    }
                    
                    # Forcar recriacao do ambiente - nao retornar aqui, continuar para recriacao
                    log_info "Ambiente sera recriado completamente..."
                } else {
                    log_success "(OK) Ambiente virtual usa Python $env_python_version (compativel)"
                    
                    # Mesmo se ja esta no ambiente, verificar se dependencias estao instaladas
                    log_info "Verificando se dependencias estao atualizadas..."
                    try {
                        poetry run python -c "import robot, pabot" -ErrorAction SilentlyContinue
                        log_success "Todas as dependencias ja estao instaladas e funcionando"
                        return $true
                    } catch {
                        log_info "Algumas dependencias estao faltando. Instalando/atualizando..."
                        poetry install
                        log_success "Dependencias atualizadas no ambiente existente"
                        return $true
                    }
                }
            } catch {
                log_warning "(WARNING) Erro ao verificar ambiente virtual, recriando..."
            }
        } else {
            # Mesmo se ja esta no ambiente, verificar se dependencias estao instaladas
            log_info "Verificando se dependencias estao atualizadas..."
            try {
                poetry run python -c "import robot, pabot" -ErrorAction SilentlyContinue
                log_success "Todas as dependencias ja estao instaladas e funcionando"
                return $true
            } catch {
                log_info "Algumas dependencias estao faltando. Instalando/atualizando..."
                poetry install
                log_success "Dependencias atualizadas no ambiente existente"
                return $true
            }
        }
    }
    
    log_warning "Nao esta em um ambiente virtual do projeto. Configurando Poetry virtual environment..."
    
    # Verificar se pyproject.toml existe
    if (-not (Test-Path "pyproject.toml")) {
        log_error "Arquivo pyproject.toml nao encontrado. Execute o script no diretorio raiz do projeto."
        return $false
    }
    
    # Configurar Poetry para criar virtual environment no projeto
    # python -m venv .venv
    # .venv\Scripts\Activate.ps1
    
    $needs_new_env = $false
    
    # Verificar se ja existe um virtual environment do Poetry
    if (-not (Test-Path ".venv") -or -not (Test-Path ".venv\pyvenv.cfg")) {
        $needs_new_env = $true
        log_info "Criando novo virtual environment com Poetry..."
        
        # Forcar criacao de novo ambiente
        try { 
            poetry env remove --all 2>$null 
        } catch { 
            # Ignorar erros na remoção do ambiente virtual
        }
        Remove-Item ".venv" -Recurse -Force -ErrorAction SilentlyContinue
        
        # Criar ambiente com Python especifico se definido
        if ($script:PYTHON_CMD) {
            log_info "Configurando Poetry para usar $script:PYTHON_CMD..."
            poetry env use $script:PYTHON_CMD
        }
    } else {
        log_info "Virtual environment encontrado. Verificando integridade..."
        
        # Verificar se o ambiente e valido
        try {
            poetry env info 2>$null | Out-Null
        } catch {
            $needs_new_env = $true
            log_warning "Ambiente virtual invalido. Recriando..."
            Remove-Item ".venv" -Recurse -Force -ErrorAction SilentlyContinue
            
            if ($script:PYTHON_CMD) {
                poetry env use $script:PYTHON_CMD
            }
        }
    }
    
    # Instalar dependencias com logs visiveis
    log_info "Instalando dependencias Python com Poetry..."
    Write-Host "[INFO] Iniciando instalacao das dependencias..." -ForegroundColor Blue
    Write-Host ""
    
    # Mostrar progresso real do Poetry
    if ($needs_new_env) {
        Write-Host "[SETUP] Criando ambiente virtual e instalando dependencias..." -ForegroundColor Yellow
    } else {
        Write-Host "[UPDATE] Atualizando dependencias no ambiente existente..." -ForegroundColor Yellow
    }
    Write-Host ""
    
    # Executar instalacao com output visivel do Poetry
    Write-Host "[POETRY] Executando: poetry install --no-root" -ForegroundColor Blue
    Write-Host "--------------------------------------------"
    
    try {
        poetry install --no-root
        if ($LASTEXITCODE -ne 0) {
            # Verificar se e problema de lock file desatualizado
            $output = poetry install --no-root 2>&1
            if ($output -match "poetry.lock.*was last generated|Run.*poetry lock") {
                log_warning "(WARNING)  Lock file desatualizado. Atualizando..."
                poetry lock
                if ($LASTEXITCODE -eq 0) {
                    log_info "Tentando instalacao novamente..."
                    poetry install --no-root
                }
            }
            if ($LASTEXITCODE -ne 0) {
                throw "Poetry install falhou com codigo de saida $LASTEXITCODE"
            }
        }
        Write-Host "-------------------------------------------------"
        Write-Host ""
        log_success "(OK) Todas as dependencias foram instaladas com sucesso!"
        
        # Verificar se Robot Framework foi instalado corretamente
        log_info "(CHECK) Verificando Robot Framework..."
        try {
            $robot_check = Invoke-Expression "poetry run python -c `"import robot; print('Robot Framework', robot.__version__)`"" 2>$null
            if ($LASTEXITCODE -eq 0 -and $robot_check) {
                log_success "(ROBOT) $robot_check"
            } else {
                log_warning "(WARNING)  Robot Framework instalado mas com problemas na verificacao"
                # Tentar forcar instalacao novamente
                log_info "Tentando reinstalar Robot Framework..."
                poetry add robotframework
            }
        } catch {
            log_warning "(WARNING)  Erro na verificacao do Robot Framework: $_"
            # Tentar forcar instalacao
            log_info "Tentando instalar Robot Framework..."
            poetry add robotframework
        }
        
        # Verificar se Pabot foi instalado corretamente
        log_info "(CHECK) Verificando Pabot..."
        try {
            $pabot_check = Invoke-Expression "poetry run python -c `"import pabot; print('Pabot instalado com sucesso')`"" 2>$null
            if ($LASTEXITCODE -eq 0 -and $pabot_check) {
                log_success "(FAST) Pabot: Parallel executor for Robot Framework"
            } else {
                log_warning "(WARNING)  Pabot instalado mas com problemas na verificacao"
                log_info "Tentando reinstalar Pabot..."
                poetry add robotframework-pabot
            }
        } catch {
            log_warning "(WARNING)  Erro na verificacao do Pabot: $_"
            log_info "Tentando instalar Pabot..."
            poetry add robotframework-pabot
        }
        
    } catch {
        Write-Host "-------------------------------------------------"
        Write-Host ""
        log_error "(ERROR) Falha na instalacao das dependencias: $_"
        return $false
    }
    
    # Verificar se o ambiente foi criado corretamente
    if (-not (Test-Path ".venv")) {
        log_error "Falha ao criar virtual environment"
        return $false
    }
    
    # Definir variavel para indicar que estamos usando Poetry
    $env:POETRY_ACTIVE = "1"
    log_success "(SUCCESS) Virtual environment configurado com Poetry e dependencias instaladas!"
    return $true
}

function AppiumVerify {
    Write-Host "Iniciando o servidor Appium em um job de segundo plano"
    # Usar variável de escopo de script para permitir cleanup no finally
    $script:AppiumJob = Start-Job -ScriptBlock { 
        appium --base-path=/wd/hub --allow-cors -p 4723 *> $null
    }
    Write-Host "Job do Appium iniciado com ID $($script:AppiumJob.Id). Aguardando inicializacao..."
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
}

function Install-Poetry {
    log_info "Poetry nao encontrado. Instalando automaticamente..."
    
    # Verificar se temos Python disponivel
    $python_cmd = if ($script:PYTHON_CMD) { $script:PYTHON_CMD } else { "python" }
    
    if (-not (Get-Command $python_cmd -ErrorAction SilentlyContinue)) {
        log_error "Python nao encontrado. Instalando Python primeiro..."
        if (-not (Install-Python3913)) {
            return $false
        }
        $python_cmd = if ($script:PYTHON_CMD) { $script:PYTHON_CMD } else { "python" }
    }
    
    # Instalar Poetry
    Write-Host "[POETRY INSTALL] Baixando e instalando Poetry..." -ForegroundColor Blue
    Write-Host "-------------------------------------------------"
    Write-Host "(DOWNLOAD) Baixando instalador do Poetry..." -ForegroundColor Yellow
    
    try {
        $installScript = (Invoke-WebRequest -Uri "https://install.python-poetry.org" -UseBasicParsing).Content
        Invoke-Expression -Command "$python_cmd -c `"$installScript`""
        
        Write-Host "-------------------------------------------------"
        Write-Host ""
        
        # Adicionar Poetry ao PATH se necessario
        $poetryPath = "${env:APPDATA}\Python\Scripts"
        if (Test-Path $poetryPath) {
            $env:PATH = "$poetryPath;$env:PATH"
        }
        
        # Verificar se instalacao funcionou
        if (Get-Command poetry -ErrorAction SilentlyContinue) {
            log_success "(OK) Poetry instalado com sucesso!"
            return $true
        } else {
            log_warning "Poetry instalado mas nao encontrado no PATH"
            log_info "Adicionando Poetry ao PATH permanentemente..."
            
            # Adicionar ao PATH do sistema para o usuario atual
            $currentPath = [Environment]::GetEnvironmentVariable("PATH", "User")
            if ($currentPath -notlike "*$poetryPath*") {
                [Environment]::SetEnvironmentVariable("PATH", "$currentPath;$poetryPath", "User")
                log_info "PATH atualizado permanentemente"
                log_info "Reinicie o terminal para que as mudancas tenham efeito"
            }
            return $true
        }
    } catch {
        Write-Host "-------------------------------------------------"
        log_error "(ERROR) Falha ao instalar Poetry: $_"
        log_info "Tente instalar manualmente:"
        Write-Host "  (Invoke-WebRequest -Uri https://install.python-poetry.org -UseBasicParsing).Content | python -"
        Write-Host "  Ou visite: https://python-poetry.org/docs/#installation"
        return $false
    }
}

function Test-AndUpdatePoetry {
    log_info "(PYTHON) Instalando pyenv para gerenciamento de versoes Python..."
}

function Install-Pyenv {
    log_info "(PYTHON) Instalando pyenv para gerenciamento de versoes Python..."
}

function Test-AndUpdatePyenv {
    log_info "(PYTHON) Instalando pyenv para gerenciamento de versoes Python..."
}

function Install-Python3913 {
    log_info "Verificando se Python 3.9.13 esta disponivel..."

    # Verificar se ja temos Python 3.9.13
    if (Get-Command python3.9.13 -ErrorAction SilentlyContinue) {
        $version = (python3.9.13 --version) -replace 'Python ', ''
        log_success "Python 3.9.13 ja instalado: $version"
        $script:PYTHON_CMD = "python3.9.13"
        return $true
    }
    
    # Verificar se o Python atual atende a versao do projeto
    if (Get-Command python3 -ErrorAction SilentlyContinue) {
        $current_version = (python3 --version) -replace 'Python ', ''
        $min_version = ($script:PROJECT_PYTHON_VERSION -split '\.')[0..1] -join '.'  # Extrair apenas major.minor
        if ([version]$current_version -ge [version]$min_version) {
            log_success "Python $current_version ja atende aos requisitos (>= $script:PROJECT_PYTHON_VERSION)"
            $script:PYTHON_CMD = "python3"
            return $true
        }
    }
    
    # Verificar Python padrao do Windows
    if (Get-Command python -ErrorAction SilentlyContinue) {
        $current_version = (python --version) -replace 'Python ', ''
        $min_version = ($script:PROJECT_PYTHON_VERSION -split '\.')[0..1] -join '.'
        if ([version]$current_version -ge [version]$min_version) {
            log_success "Python $current_version ja atende aos requisitos (>= $script:PROJECT_PYTHON_VERSION)"
            $script:PYTHON_CMD = "python"
            return $true
        }
    }
    
    log_warning "Python $script:PROJECT_PYTHON_VERSION+ nao encontrado. Tentando instalar automaticamente..."
    
    # Detectar sistema operacional e instalar Python
    $isWindowsSystem = ($IsWindows -or $env:OS -eq "Windows_NT");
    
    if ($isWindowsSystem -eq $true) {
        
        # Tentar Chocolatey
        $chocoInstalled = Get-Command choco -ErrorAction SilentlyContinue
        if ($chocoInstalled) {
            log_info "Instalando Python 3.9.13 via Chocolatey...";
            try {
                choco install python39 -y;
                $script:PYTHON_CMD = "python"
                log_success "(OK) Python 3.9.13 instalado via Chocolatey"
                return $true;
            } catch {
                log_warning "Falha ao instalar Python via Chocolatey";
            }
        }
        
        # Mostrar opcoes manuais para Windows
        log_error "Opcoes de instalacao manual:";
        Write-Host "  (TARGET) RECOMENDADO - pyenv (melhor controle):";
        Write-Host "     Chocolatey: choco install pyenv-win";
        Write-Host "     Manual: https://github.com/pyenv-win/pyenv-win";
        Write-Host "  (PACKAGE) Chocolatey:";
        Write-Host "     Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))";
        Write-Host "     choco install python39";
        Write-Host "  (WEB) Download direto: https://python.org/downloads/";
        Write-Host "  (STORE) Microsoft Store: ms-windows-store://pdp/?productid=9NRWMJP3717K";
        return $false;
    } else {
        # Sistema Unix (Linux/macOS via WSL)
        log_info "Sistema Unix detectado, usando metodos de instalacao Unix...";
        # Aqui voce poderia chamar comandos bash se necessario
        log_error "Instale Python 3.9+ manualmente para seu sistema";
        return $false;
    }
}

function Test-PythonVersionFile {
    log_info "(CHECK) Verificando configuracao da versao Python do projeto..."
    
    # Verificar se pyproject.toml existe e tem versao Python definida
    if (Test-Path "pyproject.toml") {
        $content = Get-Content "pyproject.toml" -Raw
        if ($content -match 'python = "(.+?)"') {
            $pyproject_version = $matches[1]
            $min_supported = "3.9.13"
            
            # Extrair versao limpa (remover caracteres Poetry como ^, >=, etc.)
            $clean_version = $pyproject_version -replace '[^\d\.]', ''
            $version_major_minor = ($clean_version -split '\.')[0..1] -join '.'
            
            # Verificar compatibilidade da versao
            try {
                if ([version]$version_major_minor -lt [version]$min_supported) {
                    log_warning "(WARNING) Versao no pyproject.toml ($pyproject_version) e menor que a minima suportada ($min_supported)"
                    log_info "(INFO) Considere atualizar para Python $min_supported+ no pyproject.toml"
                } else {
                    log_success "(OK) Versao Python no pyproject.toml e compativel ($pyproject_version)"
                }
            } catch {
                log_warning "(WARNING) Nao foi possivel validar a versao Python no pyproject.toml: $pyproject_version"
            }
            
            log_info "(INFO) Versao Python definida no projeto (pyproject.toml): $pyproject_version"
            log_info "Versao minima para verificacoes: $min_supported"
            
            # Verificar sincronizacao com .python-version local
            $exact_version = Get-ExactPythonVersion
            if (Test-Path ".python-version") {
                $local_version = (Get-Content ".python-version").Trim()
                if ($local_version -ne $exact_version) {
                    log_warning "(WARNING) Versao local (.python-version: $local_version) difere da versao exata para pyenv ($exact_version)"
                    log_info "(INFO) Sincronizando .python-version com versao exata para pyenv..."
                    Set-Content ".python-version" $exact_version
                    log_success "(OK) .python-version atualizado para $exact_version"
                } else {
                    log_success "(OK) .python-version sincronizado ($exact_version)"
                }
            } else {
                log_info "(INFO) Criando .python-version local baseado na versao exata..."
                Set-Content ".python-version" $exact_version
                log_success "(OK) .python-version criado com versao $exact_version"
            }
            
            log_info "(INFO) pyproject.toml e a fonte da verdade, .python-version e gerado localmente"
        } else {
            log_warning "(WARNING) Versao Python nao encontrada no pyproject.toml"
            log_info "(INFO) Adicione uma linha como: python = \"3.9.13\""
        }
    } else {
        log_error "(ERROR) pyproject.toml nao encontrado"
        log_info "(INFO) Este projeto requer Poetry e pyproject.toml"
    }
}

function Test-AndUpdateDependencies {
    if (-not (Test-Path "pyproject.toml")) {
        return
    }
    
    log_info "(CHECK) Verificando atualizacoes de dependencias Python..."
    
    # Lista de dependencias com limitacoes conhecidas devido a conflitos entre bibliotecas
    $known_conflicts = @(
        "appium-python-client",     # Limitado pelo robotframework-appiumlibrary <=4.16
        "selenium",                 # Limitado pelo robotframework-appiumlibrary <=4.16  
        "grpcio",                   # Fixado pelo robotframework-browser em 1.73.1
        "grpcio-tools",             # Fixado pelo robotframework-browser em 1.73.1
        "black",                    # Ferramenta de formatacao - updates nao criticos
        "isort",                    # Ferramenta de organizacao de imports - updates nao criticos
        "robotframework-seleniumlibrary"  # Pode ter conflitos com outras versoes RF
    )
    
    # Verificar se ha dependencias desatualizadas
    try {
        $outdated_output = ""
        try {
            $outdated_output = poetry show --outdated 2>$null
            if ($LASTEXITCODE -ne 0) { $outdated_output = "" }
        } catch {
            $outdated_output = ""
        }
        
        if ($outdated_output -and $outdated_output -notlike "*All packages are up to date*") {
            # Filtrar dependencias com conflitos conhecidos
            $filtered_lines = @()
            $outdated_lines = $outdated_output -split "`n"
            
            foreach ($line in $outdated_lines) {
                if ($line.Trim()) {
                    $package_name = ($line -split '\s+')[0]
                    $is_known_conflict = $false
                    
                    foreach ($conflict in $known_conflicts) {
                        if ($package_name -eq $conflict) {
                            $is_known_conflict = $true
                            break
                        }
                    }
                    
                    if (-not $is_known_conflict) {
                        $filtered_lines += $line
                    }
                }
            }
            
            # So mostrar warning se houver dependencias desatualizadas que NAO sao conflitos conhecidos
            if ($filtered_lines.Count -gt 0) {
                log_warning "(WARNING) Algumas dependencias estao desatualizadas:"
                $filtered_lines | ForEach-Object { Write-Host $_ }
                
                log_info "Atualizando dependencias automaticamente..."
                
                # Fazer backup do poetry.lock antes da atualizacao
                if (Test-Path "poetry.lock") {
                    Copy-Item "poetry.lock" "poetry.lock.backup"
                    log_info "(INFO) Backup do poetry.lock criado"
                }
                
                # Atualizar dependencias
                try {
                    poetry update -ErrorAction SilentlyContinue
                    log_success "(OK) Dependencias atualizadas com sucesso!"
                    
                    # Verificar se a atualizacao funcionou
                    $new_outdated = ""
                    try {
                        $new_outdated = poetry show --outdated 2>$null
                        if ($LASTEXITCODE -ne 0) { $new_outdated = "" }
                    } catch {
                        $new_outdated = ""
                    }
                    if (-not $new_outdated -or $new_outdated -like "*All packages are up to date*") {
                        log_success "(OK) Todas as dependencias estao agora atualizadas"
                    } else {
                        log_info "(INFO) Algumas dependencias ainda podem estar pendentes devido a restricoes de versao"
                    }
                } catch {
                    log_error "(ERROR) Falha ao atualizar dependencias"
                    
                    # Restaurar backup se a atualizacao falhou
                    if (Test-Path "poetry.lock.backup") {
                        Move-Item "poetry.lock.backup" "poetry.lock" -Force
                        log_info "(INFO) Backup do poetry.lock restaurado"
                    }
                    
                    log_info "(INFO) Execute manualmente: poetry update"
                }
            } else {
                log_success "(OK) Todas as dependencias estao atualizadas (conflitos conhecidos ignorados)"
            }
        } else {
            log_success "(OK) Todas as dependencias estao atualizadas"
        }
    } catch {
        log_warning "(WARNING) Erro ao verificar dependencias: $_"
    }
}

function Test-Dependencies {
    log_info "Verificando dependencias..."
    
    $errors = 0
    
    # 1. Verificar/instalar Python 3.12+
    #if (-not (Test-PythonVersion)) { $errors++ }
    
    # 2. Verificar/instalar Poetry
    # if (-not (Test-PoetryInstalled)) { $errors++ }
    
    # 3. Verificar jq (instalacao automatica para Windows)
    if (-not (Get-Command jq -ErrorAction SilentlyContinue)) {
        log_warning "jq nao esta instalado. Tentando instalar automaticamente..."
        
        if ($IsWindows -or $env:OS -eq "Windows_NT") {
            # Windows - Tentar Chocolatey primeiro, depois Scoop
            if (Get-Command choco -ErrorAction SilentlyContinue) {
                try {
                    choco install jq -y
                    log_success "(OK) jq instalado via Chocolatey"
                } catch {
                    log_error "Falha ao instalar jq via Chocolatey"
                    $errors++
                }
            } elseif (Get-Command scoop -ErrorAction SilentlyContinue) {
                try {
                    scoop install jq
                    log_success "(OK) jq instalado via Scoop"
                } catch {
                    log_error "Falha ao instalar jq via Scoop"
                    $errors++
                }
            } else {
                log_error "jq nao encontrado no Windows"
                log_info "(INFO) Opcoes de instalacao:"
                Write-Host "   • Chocolatey: choco install jq"
                Write-Host "   • Scoop: scoop install jq"
                Write-Host "   • Download direto: https://github.com/jqlang/jq/releases"
                Write-Host "   • Windows Package Manager: winget install jqlang.jq"
                $errors++
            }
        } else {
            log_error "Sistema nao suportado para instalacao automatica do jq"
            log_info "(INFO) Instale jq manualmente para seu sistema"
            $errors++
        }
    }
    
    if (Get-Command jq -ErrorAction SilentlyContinue) {
        log_success "jq encontrado"
    }
    
    # 4. Configurar virtual environment com Poetry (inclui instalacao automatica de dependencias)
    if (-not (Initialize-VirtualEnvironment)) {
        log_error "Falha na configuracao do ambiente virtual"
        $errors++
    }
    
    # 5. Verificacao final - as dependencias ja foram instaladas no Initialize-VirtualEnvironment
    if ($errors -eq 0) {
        log_info "Fazendo verificacao final das dependencias criticas..."
        
        # Verificar Robot Framework via importacao Python
        try {
            poetry run python -c "import robot" 2>$null
            if ($LASTEXITCODE -ne 0) {
                log_error "Robot Framework nao esta funcionando corretamente"
                $errors++
            }
        } catch {
            log_error "Robot Framework nao esta funcionando corretamente"
            $errors++
        }
        
        # Verificar Pabot via importacao Python
        try {
            poetry run python -c "import pabot" 2>$null
            if ($LASTEXITCODE -ne 0) {
                log_error "Pabot nao esta funcionando corretamente"
                $errors++
            }
        } catch {
            log_error "Pabot nao esta funcionando corretamente"
            $errors++
        }
        
        # Verificar AppiumLibrary
        try {
            poetry run python -c "import AppiumLibrary" 2>$null
            if ($LASTEXITCODE -ne 0) {
                log_error "AppiumLibrary nao esta funcionando corretamente"
                $errors++
            }
        } catch {
            log_error "AppiumLibrary nao esta funcionando corretamente"
            $errors++
        }
    }
    
    # Retornar sucesso se nao houve erros, falha se houve erros
    if ($errors -eq 0) {
        log_success "(SUCCESS) Todas as dependencias foram verificadas e estao funcionando!"
        
        # Verificacoes de atualizacao (nao causam falha)
        log_info "(CHECK) Executando verificacoes de atualizacao..."
        #Test-AndUpdatePyenv
        #Test-AndUpdatePoetry
        #Test-AndUpdateDependencies
        #Test-PythonVersionFile
        
        return $true
    } else {
        log_error "(ERROR) Encontrados $errors erro(s) na verificacao de dependencias"
        return $false
    }
}

function Test-Execution {
    try {
        $testsRootFolder = "tests" 
        #$tagListFile = Join-Path $PSScriptRoot "resources/devdata/test_tags.txt"

        Write-Host "Pasta do projeto: $PSScriptRoot" -ForegroundColor Gray
        Write-Host "Pasta raiz dos testes: $testsRootFolder" -ForegroundColor Gray

        $IsRunningOnMac = $false
        if ($PSVersionTable.PSEdition -eq 'Core' -and $IsMacOs) {
            $IsRunningOnMac = $true
        }
        $OsType = if ($IsWindows -or $env:OS -eq "Windows_NT") { "Windows" } elseif ($IsMacOS) { "macOS" } elseif ($IsLinux) { "Linux" } else { "Unknown" }
        Write-Host "Sistema Operacional Detectado: $OsType"

        # $tagToRun = ""
        # $tags | ForEach-Object {
        #     $tagToRun += "OR$_"
        # }

        # $tagToRun = $tagToRun.TrimStart('OR')

        # --- Execucao Android ---
        Write-Host "Limpando processos UiAutomator2 residuais"

        # Limpar processos residuais do UiAutomator2 para todos os devices
        foreach ($device in $devices) {
            Write-Host "Limpando device: $device"
            adb -s $device shell am force-stop io.appium.uiautomator2.server.test
            adb -s $device shell am force-stop io.appium.uiautomator2.server
        }

        Start-Sleep -Seconds 2

        $instances = 3
        $variables = "-v PLATFORM:Android"                     # Variáveis utilizadas na execução (PLATFORM=Android/iOS),(PABOT=True/False)
        $log_level = "-L FAIL"                                 # Nível de log para a execução (FAIL, ERROR, INFO, DEBUG, TRACE)
        $listener_RetryFailed = "--listener RetryFailed:1"     # Listeners utilizados na execução - (RetryFailed:1) significa que o teste será reexecutado uma vez em caso de falha
        $outputPathAndroid = "-d logs/Android/"                # Caminho para os logs de saída do Android
        $consolewidth = "--consolewidth 100"                   # Largura do console para melhor visualização dos logs
        Set-Location $PSScriptRoot

        #printar local de execução
        Write-Host "Local de Execucao: $PSScriptRoot" -ForegroundColor Gray

        if ($script:PABOT) {
            $variables += " -v PABOT:True --pabotlib --testlevelsplit --resourcefile resources/devdata/devices.dat --processes $instances"
            $parameters = "$variables $log_level $listener_RetryFailed $consolewidth $outputPathAndroid $testsRootFolder"
            Write-Host "poetry run pabot $parameters"
            poetry run pabot $parameters
        } else {
            $variables += " -v PABOT:False"
            $parameters = "$variables $log_level $listener_RetryFailed $consolewidth $outputPathAndroid $testsRootFolder"
            Write-Host "poetry run robot $parameters"
            poetry run robot $parameters
        }

        Write-Host "=== Concluido: testes concluidos no Android ===" -ForegroundColor Gray

        # --- Execucao iOS (se estiver no macOS) ---
        if ($IsRunningOnMac) {
            Write-Host "Aguardando antes do proximo teste de plataforma" -ForegroundColor Gray

            $outputPathiOS = "logs/iOS"
            
            #Limpa processos residuais do xuitest antes de cada teste
            Write-Host "Limpando processos xuitest residuais"
            xcrun simctl shutdown all

            Set-Location $PSScriptRoot
            poetry run robot $tagToRun --variable PLATFORM:iOS -L INFO --outputdir $outputPathiOS $testsRootFolder
            Write-Host "=== Concluido: testes concluidos no iOS ===" -ForegroundColor Gray
        }
    } finally {
    # Garante que o servidor Appium seja sempre encerrado
    Write-Host "Encerrando o servidor Appium" -ForegroundColor Yellow
    if ($script:AppiumJob) { 
        Stop-Job -Job $script:AppiumJob -ErrorAction SilentlyContinue
        Write-Host "Coletando logs do job do Appium"
        Receive-Job -Job $script:AppiumJob -ErrorAction SilentlyContinue | Out-Null
        Remove-Job -Job $script:AppiumJob -ErrorAction SilentlyContinue
        Write-Host "Job do Appium removido"
    }
    }

    log_success "Execucao de testes finalizada" 

}

function Config {    
    # Verificar se a configuracao Python funcionou
    $current_python_version = ""

    if (Get-Command python -ErrorAction SilentlyContinue) {
        $current_python_version = (python --version) -replace 'Python ', ''
    } elseif (Get-Command python3 -ErrorAction SilentlyContinue) {
        $current_python_version = (python3 --version) -replace 'Python ', ''
    }
    
    if ($current_python_version) {
        if ($current_python_version.StartsWith($target_version)) {
            log_success "(OK) Python $current_python_version ativo e funcionando"
        } else {
            log_info "(PIN) Python $current_python_version ativo (projeto usa: $target_version)"
            # Verificar se a versao ativa e compativel
            $major_minor_current = ($current_python_version -split '\.')[0..1] -join '.'
            $major_minor_target = ($target_version -split '\.')[0..1] -join '.'
            if ($major_minor_current -eq $major_minor_target) {
                log_success "(OK) Versao Python ativa e compativel com o projeto"
            } else {
                log_warning "(WARNING) Versao Python ativa pode nao ser ideal para o projeto"
                log_info "(INFO) Para usar a versao exata: pyenv shell $target_version"
            }
        }
    } else {
        log_warning "(WARNING) Nao foi possivel detectar a versao Python ativa"
    }
    
    # 3. Verificar outras dependencias do sistema
    if (-not (Test-Dependencies)) {
        log_error "Algumas dependencias criticas nao foram encontradas."
        exit 1
    }
    
    # 4. Verificar e instalar Poetry
    if (-not (Get-Command poetry -ErrorAction SilentlyContinue)) {
        log_warning "Poetry nao encontrado. Instalando automaticamente..."
        if (-not (Install-Poetry)) {
            log_error "Falha ao instalar Poetry. Verifique a instalacao."
            exit 1
        }
    } else {
        log_success "(OK) Poetry encontrado"
    }

    # 5. Configurar ambiente virtual e dependencias Python
    log_info "(CONFIG) Configurando ambiente virtual e dependencias..."
    Initialize-VirtualEnvironment

    # 7. Verificacao final do ambiente
    log_success "(SUCCESS) Ambiente configurado com sucesso!"
    log_info "(INFO) Resumo da configuracao:"
    
    $python_version = if (Get-Command python -ErrorAction SilentlyContinue) { python --version } else { "Nao detectado" }
    $poetry_version = if (Get-Command poetry -ErrorAction SilentlyContinue) { poetry --version } else { "Nao detectado" }
    #$pyenv_version = if (Get-Command pyenv -ErrorAction SilentlyContinue) { pyenv --version } else { "Nao disponivel" }
    $env_path = if (Get-Command poetry -ErrorAction SilentlyContinue) { poetry env info --path 2>$null } else { "Nao disponivel" }
    
    Write-Host "   - Python: $python_version"
    Write-Host "   - Poetry: $poetry_version" 
    #Write-Host "   - pyenv: $pyenv_version"
    Write-Host "   - Ambiente virtual: $env_path"
}

# Variaveis globais
$script:VENV_NAME = ".venv"
$script:PROJECT_ROOT = Get-Location
$script:PYTHON_MIN_VERSION = "3.9.13"      # Versao minima suportada pelo projeto
$script:PYTHON_DEFAULT_VERSION = "3.9.13"  # Versao padrao quando nao especificada
$script:PABOT = $true                      # Usar Pabot para execucao paralela
$script:IGNORE_DEPS = $Ignore

# Parar execucao em caso de erro
$ErrorActionPreference = "Stop"

# Variavel para controlar interrupcoes
$script:INTERRUPTED = $false

# Configurar ambiente de teste
Config

# Verificar Appium
AppiumVerify

# Executar testes
Test-Execution