$packageName = 'Icaros.portable'
$version = '2.2.3'
$url = "http://www.austinwagner.net/files/Icaros_v$version.zip"

try { 
    $installDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
    $exe = Join-Path "$installDir" 'IcarosConfig.exe'

    Install-ChocolateyZipPackage "$packageName" "$url" "$installDir" "$url"

    Write-Host "Activating Icaros"
    Start-Process -FilePath "$exe" -ArgumentList '-activate' -Wait

    Write-ChocolateySuccess "$packageName"
} catch {
    Write-ChocolateyFailure "$packageName" "$($_.Exception.Message)"
    throw 
}