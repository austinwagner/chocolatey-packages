$packageName = 'icaros'
$version = '3.0.3'
$installerType = 'EXE'
$sha512 = '9FDDFF658FE8981C6AB86E0C85927B49C11F0E0BCC5C94123637DC31179C5BA394C2932E55AF1D5AD7BE207BD5637051675F6B58C51F3AD7FC8A08A4E8976404'
$silentArgs = '/VERYSILENT /SUPPRESSMSGBOXES /NORESTART /SP-'

$downloadUrl = 
    Invoke-WebRequest -Uri "http://www.videohelp.com/download/Icaros_v$version.exe" -UseBasicParsing |
    select -ExpandProperty Links |
    ? { $_ -like "*Icaros_v$version*" } |
    select -First 1 -ExpandProperty href

Install-ChocolateyPackage "$packageName" "$installerType" "$silentArgs" "$downloadUrl" -checksum "$sha512" -checksumType 'sha512'
