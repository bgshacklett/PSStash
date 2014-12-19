Set-StrictMode -Version 2.0

function Resolve-Sid
{

<#

.SYNOPSIS

Resolve a given SID to a SamAccountName

.DESCRIPTION

n/a

.EXAMPLE

$SID | Resolve-Sid

Resolve a SID via the pipeline

.EXAMPLE

Resolve-Sid $SID

Resolve a SID 

#>

param(
    ## The SID to resolve
    [Parameter(
        Mandatory=$True,
        ValueFromPipeline = $True,
        ValueFromPipelineByPropertyName=$True)
    ]
    [string[]] $sids
)

begin
{
    Set-StrictMode -Version Latest
}

process
{
    Foreach ($sid in $sids)
    {
        $principal = 
            New-Object System.Security.Principal.SecurityIdentifier($sid)

        ($principal.Translate([System.Security.Principal.NTAccount]))
    }
}

}


function Resolve-SamAccountName
{

<#

.SYNOPSIS

Resolve a given SamAccountNam eto a SID

.DESCRIPTION

n/a

.EXAMPLE

$SamAccountName | Resolve-SamAccountName

Resolve a SamAccountName via the pipeline

.EXAMPLE

Resolve-SamAccountName $SamAccountName

Resolve a SamAccountName

#>

param(
    ## The SamAccountNames to resolve
    [Parameter(
        Mandatory=$True,
        ValueFromPipeline = $True,
        ValueFromPipelineByPropertyName=$True)
    ]
    [string[]] $samAccountNames
)

begin
{
    Set-StrictMode -Version Latest
}

process
{
    Foreach ($samAccountName in $samAccountNames)
    {
        $principal = 
            New-Object System.Security.Principal.NTAccount($samAccountName)

        ($principal.Translate([System.Security.Principal.SecurityIdentifier])).Value
    }
}

}

function Get-EffectiveGroupMembership
{

<#

.SYNOPSIS

Gets the effective group membership for the current user

.DESCRIPTION

n/a

.EXAMPLE

Get-EffectiveGroupMembership

Gets the effective group membership for the current user

#>

begin
{
    Set-StrictMode -Version Latest
}

process
{
    $currentUser = 
        [System.Security.Principal.WindowsIdentity]::GetCurrent()

    $currentUser.Groups | % {$_.value} | Resolve-Sid

}

}


function Get-RegisteredComObjects
{

<#

.SYNOPSIS

List all of the registered COM objects on the computer.

.DESCRIPTION

n/a

.EXAMPLE

$ Get-RegisteredComObjects

PSChildName
-----------
Access.ACCDAExtension
Access.ACCDCFile
Access.ACCDEFile
Access.ACCDTFile
Access.ACCFTFile
Access.ADEFile
Access.Application
...



#>


Get-ChildItem HKLM:\Software\Classes -ea 0 |
? {
    $_.PSChildName -match '^\w+\.\w+$' `
    -and (Get-ItemProperty "$($_.PSPath)\CLSID" -ea 0) 
} |
ft PSChildName

}


function New-GitIgnore
{
    [CmdletBinding()]
    Param (
        [Parameter(
            Mandatory=$false,
            Position=1,
            HelpMessage="What types of files are you working with?"
        )]
        [ValidateSet("Vim")]
        [String]$Type,

        [Parameter(
            Mandatory=$False,
            Position=2,
            HelpMessage="What is the path to the .gitignore file?"
        )]
        [String]$Path=".\.gitignore"
    )



    $GitIgnoreVim = 
@"
[._]*.s[a-w][a-z]
[._]s[a-w][a-z]
*.un~
Session.vim
.netrwhist
*~    
"@

    $GitIgnoreContent = ""

    If ($Type -Contains "Vim")
    {
        $GitIgnoreContent += $GitIgnoreVim
    }



    # Create the .gitignore file
    New-Item -Type File -Path $Path

    Add-Content -Value $GitIgnoreContent -Path $Path
}


function Add-GitIgnoreTypes
{
    [CmdletBinding()]
    Param(
        [Parameter(
            Mandatory=$false,
            Position=1
        )]
        [String]$Path = ".\.gitignore",
        
        [Parameter(
            Mandatory=$false,
            Position=2
        )]
        [ValidateSet("Vim")]
        [String]$Type
    )

    If ($Path)
    {
        Test-Path $Path -ErrorAction Stop
    }

    $GitIgnoreVim = 
@"
[._]*.s[a-w][a-z]
[._]s[a-w][a-z]
*.un~
Session.vim
.netrwhist
*~    
"@

    
    $GitIgnoreContent = ""

    If ($Type -Contains "Vim")
    {
        $GitIgnoreContent += $GitIgnoreVim
    }
    
    Add-Content -Value $GitIgnoreContent -Path $Path
}
