# Arquivo contendo os caminhos
$arq_e2e = "resources/devdata/path_tests.txt"

$jobs = @()

Get-Content $arq_e2e | ForEach-Object {
    $testPath = $_
    $item = ($testPath -split '/' | Select-Object -Index 1) -split '\.' | Select-Object -Index 0
    
    $outputPathAndroid = "logs/Android/$item/"
    $outputPathiOS = "logs/iOS/$item/"
    
    $jobAndroid = Start-Job -ScriptBlock {
        param ($testPath, $outputPathAndroid)
        Write-Host "Running tests ($testPath) for Android"
        pipenv run robot --variable PLATFORM:Android --outputdir $outputPathAndroid $testPath
    } -ArgumentList $testPath, $outputPathAndroid

    $jobiOS = Start-Job -ScriptBlock {
        param ($testPath, $outputPathiOS)
        Write-Host "Running tests ($testPath) for iOS"
        pipenv run robot --variable PLATFORM:iOS --outputdir $outputPathiOS $testPath
    } -ArgumentList $testPath, $outputPathiOS

    $jobs += $jobAndroid
    $jobs += $jobiOS
}

$jobs | Wait-Job

$jobs | ForEach-Object {
    $output = Receive-Job -Job $_
    $output
}

$jobs | Remove-Job