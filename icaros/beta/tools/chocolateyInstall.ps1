$packageName = 'icaros'
$version = '3.1.1_b1'
$installerType = 'EXE'
$sha512 = '6ADB81035A93E1445BD5AB7BE5F85BA057AA76C4CF752E10D11E51DF8B27B268A9EBA41AD7F0BD1AD302508726DA3C6C2D6F733F4C18EC3ACDD24D0385F00E7F'
$silentArgs = '/VERYSILENT /SUPPRESSMSGBOXES /NORESTART /SP-'

$downloadUrl = 
    Invoke-WebRequest -Uri "http://www.videohelp.com/download/Icaros_v$version.exe" -UseBasicParsing |
    select -ExpandProperty Links |
    ? { $_ -like "*Icaros_v$version*" } |
    select -First 1 -ExpandProperty href

Install-ChocolateyPackage "$packageName" "$installerType" "$silentArgs" "$downloadUrl" -checksum "$sha512" -checksumType 'sha512'
