# robot --variable PLATFORM:Android your_file.robot

$arq_e2e = "resources/devdata/path_tests.txt"
$platforms = @('Android', 'iOS')

Get-Content $arq_e2e | ForEach-Object {

    ForEach ($platform in $platforms){
        $path = $_
        $item = ($path -split '/' | Select-Object -Index 1) -split '\.' | Select-Object -Index 0

        $outputPath = "logs/${platform}/${item}/"

        $command = "robot --variable PLATFORM:${platform} --outputdir ${outputPath} ${path}"
        Write-Host "`n Executando o teste no <$platform> com o comando : $command `n"
        Invoke-Expression $command
    }
}
