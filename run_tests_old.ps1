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
        poetry run robot --variable PLATFORM:Android --variable APPIUM_PORT:4724 --outputdir $outputPathAndroid $testPath
    } -ArgumentList $testPath, $outputPathAndroid

    $jobiOS = Start-Job -ScriptBlock {
        param ($testPath, $outputPathiOS)
        Write-Host "Running tests ($testPath) for iOS"
        poetry run robot --variable PLATFORM:iOS --variable APPIUM_PORT:4723 --outputdir $outputPathiOS $testPath
    } -ArgumentList $testPath, $outputPathiOS

    $jobs += $jobAndroid
    $jobs += $jobiOS
}

$jobs | Wait-Job

$jobs | ForEach-Object {
    $output = Receive-Job -Job $_
    $output
}
