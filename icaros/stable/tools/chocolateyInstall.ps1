$packageName = 'icaros'
$version = '3.1.0'
$installerType = 'EXE'
$sha512 = '19F7691E7B99F8A852AB130CC3822B5AF5B3281E101A36B00C2470AA72FE18867EFB8BBCA114AEF9260A24128181CD35372F21BD67CFB45D713907C3E854A747'
$silentArgs = '/VERYSILENT /SUPPRESSMSGBOXES /NORESTART /SP-'

$downloadUrl = 
    Invoke-WebRequest -Uri "http://www.videohelp.com/download/Icaros_v$version.exe" -UseBasicParsing |
    Select-Object -ExpandProperty Links |
    Where-Object { $_ -like "*Icaros_v$version*" } |
    Select-Object -First 1 -ExpandProperty href

Install-ChocolateyPackage "$packageName" "$installerType" "$silentArgs" "$downloadUrl" -checksum "$sha512" -checksumType 'sha512'
