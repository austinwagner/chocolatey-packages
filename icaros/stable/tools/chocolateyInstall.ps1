$packageName = 'icaros'
$version = '3.2.1'
$installerType = 'EXE'
$sha512 = 'BDA443DF7A0E4BB174C43C2414EA52F047D2F59F48DDB52BBA1AFB9966262D42CF30270DDE48549BFEBBD293C264B03F1BB5742965B690817A6BFCDDAA179440'
$silentArgs = '/VERYSILENT /SUPPRESSMSGBOXES /NORESTART /SP-'

$downloadUrl = 
    Invoke-WebRequest -Uri "http://www.videohelp.com/download/Icaros_v$version.exe" -UseBasicParsing |
    Select-Object -ExpandProperty Links |
    Where-Object { $_ -like "*Icaros_v$version*" } |
    Select-Object -First 1 -ExpandProperty href

Install-ChocolateyPackage "$packageName" "$installerType" "$silentArgs" "$downloadUrl" -checksum "$sha512" -checksumType 'sha512'
