$packageName = 'icaros'
$version = '3.0.0'
$installerType = 'EXE'
$sha1 = '77994F4F026DB74E2116657E27B60CB9374B7C49'
$silentArgs = '/VERYSILENT /SUPPRESSMSGBOXES /NORESTART /SP-'

$downloadUrl = 
    Invoke-WebRequest -Uri "http://www.videohelp.com/download/Icaros_v$version.exe" -UseBasicParsing |
    select -ExpandProperty Links |
    ? { $_ -like "*Icaros_v$version*" } |
    select -First 1 -ExpandProperty href

Install-ChocolateyPackage "$packageName" "$installerType" "$silentArgs" "$downloadUrl" -checksum "$sha1" -checksumType 'sha1'
