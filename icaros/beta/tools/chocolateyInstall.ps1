$packageName = 'icaros'
$version = '3.3.0_b3'
$installerType = 'EXE'
$sha512 = '232F5D3B272BE3F9395E62BC867DA88EC9E891A2213DBDBE260432BB917BA7E25D9D75A2B57590026C0BC51E4E65F173018709E58F61E4EF3679FE847DF4BCDE'
$silentArgs = '/VERYSILENT /SUPPRESSMSGBOXES /NORESTART /SP-'

$downloadUrl = 
    Invoke-WebRequest -Uri "http://www.videohelp.com/download/Icaros_v$version.exe" -UseBasicParsing |
    select -ExpandProperty Links |
    ? { $_ -like "*Icaros_v$version*" } |
    select -First 1 -ExpandProperty href

Install-ChocolateyPackage "$packageName" "$installerType" "$silentArgs" "$downloadUrl" -checksum "$sha512" -checksumType 'sha512'
