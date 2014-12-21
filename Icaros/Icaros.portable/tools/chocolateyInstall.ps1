$packageName = 'Icaros.portable'
$version = '2.2.6'
$sha1 = '1bb27bd7ab5d945af1c10a585471f0a4fc4862ae'
$url = "http://www.austinwagner.net/files/Icaros_v$version.zip"

try { 
    $installDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
    $exe = Join-Path "$installDir" 'IcarosConfig.exe'

    Install-ChocolateyZipPackage "$packageName" "$url" "$installDir" "$url" -checksum "$sha1" -checksumType 'sha1' -checksum64 "$sha1" -checksumType64 'sha1'

    Write-Host "Activating Icaros"
    Start-Process -FilePath "$exe" -ArgumentList '-activate' -Wait

    Write-ChocolateySuccess "$packageName"
} catch {
    Write-ChocolateyFailure "$packageName" "$($_.Exception.Message)"
    throw 
}