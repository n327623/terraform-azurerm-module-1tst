<#
.SYNOPSIS
Run Pester and export results in NUnitXml format
.DESCRIPTION
Run Pester and export results in NUnitXml format
.PARAMETER BuildNumber
Should be provided by Task or Build Variable
.EXAMPLE
.\runner.tests.ps1 -BuildNumber 123
#>

[CmdLetBinding()]
param (
    [string]$TestFilePath = "",
    [string]$OutputDirectory = ".",
    [hashtable]$TestParameters,
    [string]$BuildNumber = (Get-Random -Maximum 999),
    [string]$Tag = ''
)

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$fixturesDir = Join-Path -Path $scriptDir -ChildPath "\fixtures"

if ($Tag -eq "UT") {
    $TestFilePath = "$fixturesDir/frame1/environment.tests.ps1"
}
elseif ($Tag -eq "IT") {
    $TestFilePath = "$fixturesDir/frame2/environment.tests.ps1"
}
else {
    Write-Output "##vso[task.logissue type=error;] Please choose between UT/IT tests in tag parameter."
    return
}

Write-Output "My filepath: $TestFilePath"

$testFile = $(Split-Path $TestFilePath -leaf).Replace(".ps1", "");
$outputFile = "$OutputDirectory\TEST-$testFile$Tag-$BuildNumber.xml"
$script = @{ Path = $TestFilePath; Parameters = $TestParameters }

Invoke-Pester -Script $script -OutputFile $outputFile -OutputFormat NUnitXml -Tag $Tag
