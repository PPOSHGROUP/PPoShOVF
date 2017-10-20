function Invoke-POVFPester {
  <#
      .SYNOPSIS
      Uses Invoke-Pester and Write-POVFPesterEventLog to generate EventLog output and file NUnit XML output

      .DESCRIPTION
      If OutputFolder is provided it will generate xml file with pester tests results.
      Will also generate events to EventLog Application with provided Source and Event ID using Write-POVFPesterEventLog function

      .PARAMETER PesterFile
      Location of file with pester tests.

      .PARAMETER EventSource
      Name for EventSource to be used in writing events to EventLog

      .PARAMETER EventID
      Base ID to pass to Write-POVFPesterEventLog

      .EXAMPLE
      Invoke-POVFPester -PesterFile C:\SomePath\Pester1.Tests.ps1 -EventSource MySource -EventID 1000
      Will run all tests from Pester1.Tests.ps1 file.
      Success tests will be written to EventLog Application with MySource as source and EventID 1001.
      Errors tests will be written to EventLog Application with MySource as source and EventID 1002.
  #>

  [CmdletBinding()]
  [OutputType([Void])]
  Param(
    [Parameter(Mandatory=$True,
      ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$True)]
    [ValidateScript({Test-Path $_ -Type Leaf})]
    [string[]]
    $PesterFile,

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
    $EventBaseID,

    [Parameter(Mandatory=$false,
      ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$True)]
    [ValidateScript({Test-Path $_ -Type Container})]
    [String]
    $OutputFolder
  )

  Begin{
    $pesterParams =@{
      Show = 'None'
      PassThru = $true
    }
}
  Process{
    ForEach ($file in $PesterFile){
      Write-Log -Info -Message "Processing PesterFile {$file}"
      if($PSBoundParameters.ContainsKey('OutputFolder')) {
        $timestamp = Get-Date -Format 'yyyyMMdd_HHmm'
        $fileNameTemp = (split-Path $file -Leaf).replace('.ps1','')
        $childPath = "{0}_{1}_PesterResults.xml" -f $fileNameTemp, $timestamp

        $fileName = Join-Path -Path $OutputFolder -ChildPath $childPath
        $pesterParams.OutputFile = $fileName
        $pesterParams.OutputFormat ='NUnitXml'
        Write-Log -Info -Message "Results for Pester file {$file} will be written to {$($pesterParams.OutputFile)}"
      }
      $tests = Invoke-Pester $file @pesterParams
      if($PSBoundParameters.ContainsKey('WriteToEventLog')){
        $pesterEventParams=@{
          PesterTestsResults = $tests
          EventSource = $EventSource
          EventIDBase = $EventBaseID
        }
        Write-Log -Info -Message "Writing test results to Event Log {Application} with Event Source {$EventSource} and EventBaseID {$EventBaseID}"
        Write-POVFPesterEventLog @pesterEventParams
      }

      Write-Log -Info -Message "Pester File {$file} Processed."
    }
  }
  End {
  }
}