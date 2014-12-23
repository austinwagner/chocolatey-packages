$packageName = 'ps-fileassociation'
$revision = '4167a7fab0f27011e746f078ed148d27c0e2d59d'
$urlBase = "https://raw.github.com/austinwagner/chocolatey-packages/$revision/$packageName/scripts"
$scripts = @(
    @('Register-FileAssociation.ps1', '4381346F2AA7ADBC51F6D8D58356C8AE029C411D'),
    @('Unregister-FileAssociation.ps1', 'CF0086EE4EBBEE92F5D8E87A95D4F295D3F5DF9E')
)


$installDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

for ($tuple in $scripts)
{
    $script = $tuple[0]
    $sha1 = $tuple[1]
    
    $scriptInstallPath = Join-Path "$installDir" "$script"
    Install-ChocolateyPowershellCommand -PackageName "$packageName" -PsFileFullPath "$scriptInstallPath" -Url "$urlBase/$script" -checksum "$sha1" -checksumType 'sha1'
}