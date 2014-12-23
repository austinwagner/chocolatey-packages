# The MIT License (MIT)
# 
# Copyright (c) 2014 Austin Wagner
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

<#
.SYNOPSIS
    Creates a file type association based off file extension.

.DESCRIPTION
    Registers the given extension into the Windows Registry to invoke the provided command. The command should take the form of '"C:\Path\To\Program.exe" "%1"'.
    The placeholder %1 will be replaced with the file path by Windows.

.PARAMETER Scope
    Selects the scope of the registration. Must be either 'LocalMachine' or 'User'.

.PARAMETER AppName
    The name of the application this extension will be registered to. Will be combined with Extension to create a unique name in the registry.

.PARAMETER Extension
    The extension to register (without the dot).

.PARAMETER Command
    The command that will be executed when a file of the given type is opened from Explorer. %1 in this string will be replaced with the file path.
    Ensure this parameter is properly quoted.

.PARAMETER Icon
    Path to the icon that represents this type. If the icon is inside a DLL or EXE, the path can be followed by a comma and a number indicating the index of the icon resource.

.PARAMETER Force
    Force creation of the file association even if 'AppName.Command' already exists.
#>
param (
    [ValidateSet('User', 'LocalMachine', IgnoreCase = $true)]
    [Parameter(Mandatory=$true)]
    [string]
    $Scope,

    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty]
    [string]
    $AppName,

    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty]
    [string]
    $Extension,
    
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty]
    [string]
    $Command,

    [string]
    $Description,

    [string]
    $Icon,

    [switch]
    $Force
)

$hive = switch ($Scope)
        {
            'User' { 'HKCU' }
            'LocalMachine' { 'HKLM' }
        }

$classesRoot = "${hive}:\Software\Classes"
$fullName = "$AppName.$Extension"

Set-Location $classesRoot | Out-Null
New-Item -Name $fullName -Force:$Force.IsPresent | Out-Null

Set-Location $fullName | Out-Null

if ($Description)
    { Set-Item -Path . -Value $Description | Out-Null }

if ($Icon)
{
    New-Item -Name 'Default Icon' | Out-Null
    Set-Location 'Default Icon' | Out-Null
    Set-Item -Path . -Value "$Icon" | Out-Null
    Set-Location .. | Out-Null
}

New-Item -Name 'shell\open\command' | Out-Null
Set-Location 'shell\open\command' | Out-Null
Set-Item -Path . -Value "$Command" | Out-Null

New-Item -Name "$classesRoot\.$Extension" -ErrorAction Ignore | Out-Null
Set-Item -Path "$classesRoot\.$Extension" -Value $fullName | Out-Null