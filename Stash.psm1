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
