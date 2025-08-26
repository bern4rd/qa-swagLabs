# Arquivo contendo os caminhos
$arq_e2e = "resources/devdata/test_tags.txt"

$jobs = @()

Get-Content $arq_e2e | ForEach-Object {
    $tag = $_

    $outputPathAndroid = "logs/Android/$item/"
    $outputPathiOS = "logs/iOS/$item/"

    $jobAndroid = Start-Job -ScriptBlock {
        param ($testPath, $outputPathAndroid)
        Write-Host "Running tests ($testPath) for Android"
        poetry run robot --variable PLATFORM:Android --variable APPIUM_PORT:4724 --outputdir -i $tag $outputPathAndroid $testPath
    } -ArgumentList $testPath, $outputPathAndroid

    $jobiOS = Start-Job -ScriptBlock {
        param ($testPath, $outputPathiOS)
        Write-Host "Running tests ($testPath) for iOS"
        poetry run robot --variable PLATFORM:iOS --variable APPIUM_PORT:4723 --outputdir -i $tag $outputPathiOS $testPath
    } -ArgumentList $testPath, $outputPathiOS

    $jobs += $jobAndroid
    $jobs += $jobiOS
}

$jobs | Wait-Job

$jobs | ForEach-Object {
    $output = Receive-Job -Job $_
    $output
}
