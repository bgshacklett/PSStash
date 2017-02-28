Set-StrictMode -Version 2.0

function ConvertTo-EncryptedString
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [string] $ClearString,

        [Parameter(Mandatory=$false)]
        [byte[]] $Key
    )
    Begin
    {
    }

    Process
    {
        $secureString =
            ConvertTo-SecureString -String $ClearString -AsPlainText -Force

        # If the key is null, it will be ignored.
        $encryptedString =
            ConvertFrom-SecureString -SecureString $secureString -Key $Key

        $encryptedString
    }

    End
    {
    }
}


function New-Credential
{
    param(
        [Parameter(Mandatory=$True)]
        [string] $UserName,

        [Parameter(Mandatory=$True)]
        [SecureString] $Password
    )

    $credentials =
        New-Object System.Management.Automation.PSCredential (
            $Username,
            $Password
        )

    $credentials
}


function New-AesKey
{
    $key = New-Object byte[](32)
    $rng = [System.Security.Cryptography.RNGCryptoServiceProvider]::Create()

    $rng.GetBytes($key)

    $key
}

function New-UnmanagedServiceAccount
{

param(
    ## The SamAccountName of the new service account.
    [Parameter(Mandatory=$True)]
    [string] $SamAccountName,

    ## The Path to the new service account.
    [Parameter(Mandatory=$False)]
    [string] $Path = "CN=Users,$((Get-ADDomain).DistinguishedName)",

    ## A short description of the new service account's usage.
    [Parameter(Mandatory=$False)]
    [string] $Description = ""
)

New-ADUser `
    -SamAccountName $SamAccountName `
    -Path $Path `
    -PasswordNeverExpires $True `
    -CannotChangePassword $True
    -Description = $Description `
    -PassThru |

Set-ADAccountPassword `
    -Reset
}



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
        [ValidateSet("Vim","Go")]
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
##### Vim Files #####

[._]*.s[a-w][a-z]
[._]s[a-w][a-z]
*.un~
Session.vim
.netrwhist
*~    


"@

    $GitIgnoreGo = 
@"
##### Golang #####

# Compiled Object files, Static and Dynamic libs (Shared Objects)
*.o
*.a
*.so

# Folders
_obj
_test

# Architecture specific extensions/prefixes
*.[568vq]
[568vq].out

*.cgo1.go
*.cgo2.c
_cgo_defun.c
_cgo_gotypes.go
_cgo_export.*

_testmain.go

*.exe
*.test
*.prof

# Output of the go coverage tool, specifically when used with LiteIDE
*.out

# External packages folder
vendor/
"@

    $GitIgnoreContent = ""

    If ($Type -Contains "Vim")
    {
        $GitIgnoreContent += $GitIgnoreVim
    }

    If ($Type -Contains "Go")
    {
        $GitIgnoreContent += $GitIgnoreGo
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
        [ValidateSet("Vim","Go")]
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

    $GitIgnoreGo = 
@"
##### Golang #####
# Compiled Object files, Static and Dynamic libs (Shared Objects)
*.o
*.a
*.so

# Folders
_obj
_test

# Architecture specific extensions/prefixes
*.[568vq]
[568vq].out

*.cgo1.go
*.cgo2.c
_cgo_defun.c
_cgo_gotypes.go
_cgo_export.*

_testmain.go

*.exe
*.test
*.prof

# Output of the go coverage tool, specifically when used with LiteIDE
*.out

# External packages folder
vendor/
"@

    
    $GitIgnoreContent = ""

    If ($Type -Contains "Vim")
    {
        $GitIgnoreContent += $GitIgnoreVim
    }

    If ($Type -Contains "Go")
    {
        $GitIgnoreContent += $GitIgnoreGo
    }
    
    Add-Content -Value $GitIgnoreContent -Path $Path
}
