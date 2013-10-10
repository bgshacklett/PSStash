function Set-Clipboard 
{

<#

.SYNOPSIS

Sends the given input to the Windows clipboard.

.DESCRIPTION

The code in this function is exepted from the MIT license that
the rest of the repository is licensed under due to lack of
rights to relicense. 

From Windows PowerShell Cookbook
by Lee Holmes (http://www.leeholmes.com/guide)
ISBN-13: 978-1449320683
Publisher: O'Reilly

Modifications by Brian G. Shacklett <brian@digital-traffic.net>
Summary: Converted to Powershell Function.

.EXAMPLE

dir | Set-Clipboard
This example sends the view of a directory listing to the clipboard

.EXAMPLE

Set-Clipboard "Hello World"
This example sets the clipboard to the string, "Hello World".

#>

param(
    ## The input to send to the clipboard
    [Parameter(ValueFromPipeline = $true)]
    [object[]] $InputObject
)

begin
{
    Set-StrictMode -Version Latest
    $objectsToProcess = @()
}

process
{
    ## Collect everything sent to the script either through
    ## pipeline input, or direct input.
    $objectsToProcess += $inputObject
}

end
{
    ## Launch a new instance of PowerShell in STA mode.
    ## This lets us interact with the Windows clipboard.
    $objectsToProcess | PowerShell -NoProfile -STA -Command {
        Add-Type -Assembly PresentationCore

        ## Convert the input objects to a string representation
        $clipText = ($input | Out-String -Stream) -join "`r`n"

        ## And finally set the clipboard text
        [Windows.Clipboard]::SetText($clipText)
    }
}

}
