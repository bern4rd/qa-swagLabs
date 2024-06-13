# Defina o arquivo contendo os caminhos
$arq_e2e = "resources/devdata/path_tests.txt"

# Lista para armazenar os objetos de trabalho
$jobs = @()

# Leia o conteúdo do arquivo e processe cada linha
Get-Content $arq_e2e | ForEach-Object {
    $testPath = $_
    $item = ($testPath -split '/' | Select-Object -Index 1) -split '\.' | Select-Object -Index 0
    
    # Defina o caminho de saída para cada plataforma
    $outputPathAndroid = "logs/Android/$item/"
    $outputPathiOS = "logs/iOS/$item/"
    
    # Execute os comandos em paralelo
    $jobAndroid = Start-Job -ScriptBlock {
        param ($testPath, $outputPathAndroid)
        Write-Host "Running tests ($testPath) for Android"
        robot --variable PLATFORM:Android --outputdir $outputPathAndroid $testPath
    } -ArgumentList $testPath, $outputPathAndroid

    $jobiOS = Start-Job -ScriptBlock {
        param ($testPath, $outputPathiOS)
        Write-Host "Running tests ($testPath) for iOS"
        robot --variable PLATFORM:iOS --outputdir $outputPathiOS $testPath
    } -ArgumentList $testPath, $outputPathiOS

    $jobs += $jobAndroid
    $jobs += $jobiOS
}

# Aguardar a conclusão de todos os trabalhos
$jobs | Wait-Job

# Obter e exibir os resultados dos trabalhos
$jobs | ForEach-Object {
    $output = Receive-Job -Job $_
    $output
}

# Remover todos os trabalhos
$jobs | Remove-Job