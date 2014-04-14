$packageName = 'Icaros.portable'
$version = '2.2.3'

try { 
    $installDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
    $exe = Join-Path "$installDir" 'IcarosConfig.exe'

    Write-Host "Deactivating Icaros"
    Start-Process -FilePath "$exe" -ArgumentList '-activate' -Wait

    Write-ChocolateySuccess "$packageName"
} catch {
    Write-ChocolateyFailure "$packageName" "$($_.Exception.Message)"
    throw 
}