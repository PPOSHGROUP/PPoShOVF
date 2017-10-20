# PPoShOVF

[![Build status](https://ci.appveyor.com/api/projects/status/ov7ipjqd33j2cxco?svg=true)](https://ci.appveyor.com/project/PPOSHGROUP/pposhovf)

[![Build status](https://ci.appveyor.com/api/projects/status/ov7ipjqd33j2cxco/branch/master?svg=true)](https://ci.appveyor.com/project/PPOSHGROUP/pposhovf/branch/master)


PPoShOVF
=============

PowerShell module with basic Tools for Operation Validation Framework


## Instructions

```powershell
# One time setup
    # Download the repository
    # Unblock the zip
    # Extract the PPoShOVF folder to a module path (e.g. $env:USERPROFILE\Documents\WindowsPowerShell\Modules\)

    #Simple alternative, if you have PowerShell 5, or the PowerShellGet module:
        Install-Module PPoShOVF

# Import the module.
    Import-Module PPoShOVF #Alternatively, Import-Module \\Path\To\PPoShOVF

# Get commands in the module
    Get-Command -Module PPoShOVF

# Get help
    Get-Help about_PPoShOVF
```