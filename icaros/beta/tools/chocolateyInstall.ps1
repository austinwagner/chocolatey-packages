$packageName = 'icaros'
$version = '3.1.0_b2'
$installerType = 'EXE'
$sha512 = 'B0E11C16A48C04621FE5CDC208CD840EF78A550B338968FAF863A14C6997AAC28EDBED522692DE6B72D26A704CDB09EA410A70A3482C4E205611C05C9E151DD9'
$silentArgs = '/VERYSILENT /SUPPRESSMSGBOXES /NORESTART /SP-'

$downloadUrl = 
    Invoke-WebRequest -Uri "http://www.videohelp.com/download/Icaros_v$version.exe" -UseBasicParsing |
    select -ExpandProperty Links |
    ? { $_ -like "*Icaros_v$version*" } |
    select -First 1 -ExpandProperty href

Install-ChocolateyPackage "$packageName" "$installerType" "$silentArgs" "$downloadUrl" -checksum "$sha512" -checksumType 'sha512'
