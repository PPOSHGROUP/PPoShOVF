function Invoke-POVFTest {
  <#
      .SYNOPSIS
      Based on Configuration and tests from DiagnosticsFolder will perform Pester Tests.

      .DESCRIPTION
      Will read provided Configuration into variable. Then will read Pester tests from ps1 files from DiagnosticsFolder and perform Pester Tests with Invoke-pOVFPesterParams.
      If WriteToEventLog is enabled will write EventLog entries.
      If OutputFolder is provided - will generate NUnit xml files with results

      .PARAMETER POVFTestFile
      hashtable @{
        Test = Filepath
        Parameters = [hashtable]$Parameters
      }

      .PARAMETER DiagnosticsFolder
      Location where Diagnostic Tests are stored

      .PARAMETER WriteToEventLog
      If enabled will generate EventLog entries with Write-pOVFPesterEventLog function.

      .PARAMETER EventSource
      Name for EventSource to be used in writing events to EventLog

      .PARAMETER EventIDBase
      Base ID to pass to Write-pOVFPesterEventLog
      Success tests will be written to EventLog Application with MySource as source and EventIDBase +1.
      Errors tests will be written to EventLog Application with MySource as source and EventIDBase +2.


      .PARAMETER OutputFolder
      Location where NUnit xml with Pester results will be stored

      .PARAMETER Credential
      Credentials to be used in remote tests

      .PARAMETER POVFPSSession
      PSSession to be used in remote tests

      .PARAMETER Show
      If enabled will show pester results to console.

      .EXAMPLE
      Invoke-POVFTest -Configuration $configuration -PesterFile C:\SomePath\Pester1.Tests.ps1 -EventSource MySource -EventID 1000
      Will run all tests from Pester1.Tests.ps1 file.
      Success tests will be written to EventLog Application with MySource as source and EventID 1001.
      Errors tests will be written to EventLog Application with MySource as source and EventID 1002.

  #>


  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory=$True, HelpMessage='File with tests',
    ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$True)]
    [ValidateScript({Test-Path -Path $_ -PathType Leaf})]
    [string[]]
    $POVFTestFile,

    [Parameter(Mandatory=$false, HelpMessage='hashtable with Configuration',
    ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$True)]
    [hashtable]
    $POVFTestFileParameters,

    [Parameter(Mandatory=$false,
    ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$True)]
    [switch]
    $WriteToEventLog,

    [Parameter(Mandatory=$false,
    ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$True)]
    [string]
    $EventSource,

    [Parameter(Mandatory=$false,
    ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$True)]
    [int32]
    $EventIDBase,

    [Parameter(Mandatory=$false,HelpMessage='Folder with Pester test results',
    ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$True)]
    [ValidateScript({Test-Path $_ -Type Container -IsValid})]
    [String]
    $OutputFolder,

    [Parameter(Mandatory=$false,HelpMessage='FileName for Pester test results',
    ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$True)]
    [ValidateScript({Test-Path $_ -Type Leaf -IsValid})]
    [String]
    $OutputFile,

    [Parameter(Mandatory=$false,HelpMessage='Show Pester Tests on console',
    ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$True)]
    [String]
    $Show,

    [Parameter(Mandatory=$false,HelpMessage='Tag for Pester ',
    ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$True)]
    [string[]]
    $Tag
  )
  begin {
    $pesterParams =@{
      PassThru = $true
    }
    if($PSBoundParameters.ContainsKey('Show')){
      Write-Log -Info -Message "Will show test results to console"
      $pesterParams.Show = $Show
    }
    else {
      $pesterParams.Show = 'None'
    }
    if($PSBoundParameters.ContainsKey('Tag')){
      $pesterParams.Tag = $Tag
    }
  }
  process{
    
    
    ForEach ($file in $POVFTestFile){
      Write-Log -Info -Message "Processing PesterFile {$file}"
      $pesterParams.Script = @{
        Path = $file
        Parameters = $POVFTestFileParameters
      }
      if($PSBoundParameters.ContainsKey('OutputFolder')) {
        $timestamp = Get-Date -Format 'yyyyMMdd_HHmm'
        if($PSBoundParameters.ContainsKey('OutputFile')){
          $fileNameTemp = $OutputFile
        }
        else { 
          $fileNameTemp = (split-Path $file -Leaf).replace('.ps1','')
        }
        $childPath = "{0}_{1}_PesterResults.xml" -f $fileNameTemp, $timestamp

        $fileName = Join-Path -Path $OutputFolder -ChildPath $childPath
        $pesterParams.OutputFile = $fileName
        $pesterParams.OutputFormat ='NUnitXml'
        Write-Log -Info -Message "Results for Pester file {$file} will be written to {$($pesterParams.OutputFile)}"
      }
      #region Perform Tests
      $povfTests = Invoke-Pester @pesterParams
      #endregion 
      if($PSBoundParameters.ContainsKey('WriteToEventLog')){
        $pesterEventParams=@{
          PesterTestsResults = $povfTests
          EventSource = $EventSource
          EventIDBase = $EventIDBase
        }
        Write-Log -Info -Message "Writing test results to Event Log {Application} with Event Source {$EventSource} and EventIDBase {$EventIDBase}"
        Write-POVFPesterEventLog @pesterEventParams
      }

      Write-Log -Info -Message "Pester File {$file} Processed."
    }
  }
}