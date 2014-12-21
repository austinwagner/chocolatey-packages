<#
.SYNOPSIS
    Removes a file type association based off file extension.

.DESCRIPTION
    Unegisters the given extension's association and deletes the entry created by Register-FileAssociation. 
    Will not unregister if the association does not match the one created by Register-FileAssociation unless the Force switch is given.
    The complementary Register-FileAssoctation entry will always be deleted.

.PARAMETER Scope
    Selects the scope of the registration to remove. Must be either 'LocalMachine' or 'User'.

.PARAMETER AppName
    The name of the application this extension will be unregistered from. Will be combined with Extension to create a unique name in the registry.

.PARAMETER Extension
    The extension to unregister (without the dot).

.PARAMETER FullName
    The name of the entry in the registry if it does not follow the ${AppName}.${Extension} format used by Register-FileAssociation.

.PARAMETER Force
    Force any registration for the given extension to be removed even if it was not created by the matching Register-FileAssociation.
#>
param (
    [ValidateSet('User', 'LocalMachine', IgnoreCase = $true)]
    [Parameter(Mandatory=$true)]
    [string]
    $Scope,

    [Parameter(Mandatory=$true, ParameterSetName='MatchRegisterParams')]
    [ValidateNotNullOrEmpty()]
    [string]
    $AppName,

    [Parameter(Mandatory=$true, ParameterSetName='MatchRegisterParams')]
    [Parameter(Mandatory=$true, ParameterSetName='FullName')]
    [ValidateNotNullOrEmpty()]
    [string]
    $Extension,

    [Parameter(Mandatory=$true, ParameterSetName='FullName')]
    [ValidateNotNullOrEmpty()]
    [string]
    $FullName,

    [switch]
    $Force
)

$hive = switch ($Scope)
        {
            'User' { 'HKCU' }
            'LocalMachine' { 'HKLM' }
        }

$classesRoot = "${hive}:\Software\Classes"

if ($PSCmdlet.ParameterSetName -eq 'MatchRegisterParams')
    { $FullName = "$AppName.$Extension" }

$extensionPath = "$classesRoot\.$Extension"

$extensionKeyValue = Get-Item $extensionPath -ErrorAction Ignore | Where-Object { $_ -ne $null } | ForEach-Object { $_.GetValue('') }

if (-not $Force -and $extensionKeyValue -ine $fullName)
{
    Write-Warning ".$Extension is not associated with $AppName. Not removing." 
}
else
{
    $removeFailed = $false

    if ((Get-Item $extensionPath).ValueCount -gt 1)
    {
        $removeFailed = $true
    }
    else
    {
        Remove-Item $extensionPath -ErrorAction Ignore -ErrorVariable removeFailed
    }

    if ($removeFailed)
    {
        Write-Verbose "$extensionPath has other subkeys or values that were not created by Register-FileAssociation. Changing default value instead of removing key."
        Set-Item -Path $extensionPath -Value '' | Out-Null
    }
}

Remove-Item "$classesRoot\$fullName" -Recurse
