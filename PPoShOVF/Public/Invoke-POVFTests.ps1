function Invoke-POVFTests {
    <#
        .SYNOPSIS
        Based on Configuration and tests from DiagnosticsFolder will perform Pester Tests.
  
        .DESCRIPTION
        Will read provided Configuration into variable. Then will read Pester tests from ps1 files from DiagnosticsFolder and perform Pester Tests with Invoke-POVFPester. 
        If WriteToEventLog is enabled will write EventLog entries.
        If OutputFolder is provided - will generate NUnit xml files with results
  
        .PARAMETER pOVFConfiguration
        PSCustomObject with configuration for Diagnostic tests.
  
        .PARAMETER DiagnosticsFolder
        Location where Diagnostic Tests are stored
  
        .PARAMETER WriteToEventLog
        If enabled will generate EventLog entries with Write-POVFPesterEventLog function. 
  
        .PARAMETER EventSource
        Name for EventSource to be used in writing events to EventLog
  
        .PARAMETER EventBaseID
        Base ID to pass to Write-POVFPesterEventLog
        Success tests will be written to EventLog Application with MySource as source and EventIDBase +1.
        Errors tests will be written to EventLog Application with MySource as source and EventIDBase +2.
        
  
        .PARAMETER OutputFolder
        Location where NUnit xml with Pester results will be stored
  
        .PARAMETER Credential
        Credentials to be used in remote tests
  
        .EXAMPLE

  Invoke-POVFTests -Configuration $configuration -PesterFile C:\SomePath\Pester1.Tests.ps1 -EventSource MySource -EventID 1000
      Will run all tests from Pester1.Tests.ps1 file.
      Success tests will be written to EventLog Application with MySource as source and EventID 1001.
      Errors tests will be written to EventLog Application with MySource as source and EventID 1002.
    
    #>
  
  
    [CmdletBinding()]
    param
    (
      [Parameter(Mandatory=$True, HelpMessage='',
      ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$True)]
      [PSCustomObject]
      $pOVFConfiguration,
  
      [Parameter(Mandatory=$True, HelpMessage='',
      ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$True)]
      [ValidateScript({Test-Path $_ -Type Container})]
      [System.String]
      $DiagnosticsFolder,
  
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
  
      [Parameter(Mandatory=$false,HelpMessage='',
      ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$True)]
      [ValidateScript({Test-Path $_ -Type Container -IsValid})]
      [String]
      $OutputFolder,
  
      [Parameter(Mandatory=$false,
      ValueFromPipeline,ValueFromPipelineByPropertyName)]
      [System.Management.Automation.Credential()][System.Management.Automation.PSCredential]
      $Credential  = [System.Management.Automation.PSCredential]::Empty
    )
    
    process{
      $pesterFile = Get-ChildItem -Path $DiagnosticsFolder -Recurse -File | 
                                Where-Object {$_.Name -match 'Tests.ps1'} | 
                                Select-Object -ExpandProperty FullName
      $pOVFPester = @{
        PesterFile = $pesterFile
      }
      if($PSBoundParameters.ContainsKey('OutputFolder')) {
        $pOVFPester.OutputFolder =@{
          OutputFolder = $OutputFolder
        }
      }
      if($PSBoundParameters.ContainsKey('WriteToEventLog')){
        $pOVFPester=@{
          WriteToEventLog = $true
          EventSource = $EventSource
          EventIDBase = $EventBaseID
        }
      }
      if($PSBoundParameters.ContainsKey('Credential')){
        $pOVFCredential = $Credential
        Write-Log -Info -Message "Will use {$($pOVFCredential.UserName)} in diagnostics tests"
      }
      Invoke-POVFPester @pOVFPester
    } 
  }  