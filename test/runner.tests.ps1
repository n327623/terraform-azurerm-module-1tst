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
    [string]$TestFilePath = "$PSScriptRoot/fixtures/frame1/environment.tests.ps1",
    [string]$OutputDirectory = ".",
    [hashtable]$TestParameters,
    [string]$BuildNumber = (Get-Random -Maximum 999),
    [string]$Tag = ''
)

$testFile = $(Split-Path $TestFilePath -leaf).Replace(".ps1", "");
$outputFile = "$OutputDirectory\TEST-$testFile$Tag-$BuildNumber.xml"
$script = @{ Path = $TestFilePath; Parameters = $TestParameters }

Invoke-Pester -Script $script -OutputFile $outputFile -OutputFormat NUnitXml -Tag $Tag
